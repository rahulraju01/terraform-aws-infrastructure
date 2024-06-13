#!/bin/bash
log_file="/var/log/deploy.log"
 execute_command() {
    execute_step_info="$1"
    execute_command="$2"
    echo "$execute_step_info" >> "$log_file"
    eval "$execute_command" >> "$log_file" 2>&1
  }

execute_command "---- Updating packages ----" "sudo apt update"
execute_command "---- Installing maven ----" "sudo apt install -y maven"
execute_command "---- Maven version ----" "mvn -version"
execute_command "---- Installing open jdk 17 ----" "sudo apt install -y openjdk-17-jdk openjdk-17-jre"
execute_command "---- Java version ----" "java -version"
execute_command "---- Creating tomcat directory ----" "mkdir /opt/tomcat"
execute_command "---- Adding user as tomcat ----" "useradd -m -d /opt/tomcat -U -s /bin/false tomcat"
execute_command "---- Downloading tomcat packages ----" "wget -P /tmp  https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.89/bin/apache-tomcat-9.0.89.tar.gz"
execute_command "---- Extracting downloaded packages to tomcat location ----" "tar xzvf /tmp/apache-tomcat-9.0.89.tar.gz -C /opt/tomcat --strip-components=1"
execute_command "---- Giving owernship to tomcat user ----" "chown -R tomcat:tomcat /opt/tomcat/"
execute_command "---- Giving access to tomcat bin directory ----" "chmod -R u+x /opt/tomcat/bin"

getTomcatUserConfig() {
    cat << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<tomcat-users xmlns="http://tomcat.apache.org/xml"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xsi:schemaLocation="http://tomcat.apache.org/xml tomcat-users.xsd"
              version="1.0">

<role rolename="manager-gui" />
<user username="manager" password="manager_password" roles="manager-gui" />

<role rolename="admin-gui" />
<user username="admin" password="admin_password" roles="manager-gui,admin-gui" />
</tomcat-users>
EOF
}

getManagerContextData() {
    cat << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<Context antiResourceLocking="false" privileged="true" >
  <CookieProcessor className="org.apache.tomcat.util.http.Rfc6265CookieProcessor"
                   sameSiteCookies="strict" />
 <!-- <Valve className="org.apache.catalina.valves.RemoteAddrValve"
         allow="127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1" /> -->
  <Manager sessionAttributeValueClassNameFilter="java\.lang\.(?:Boolean|Integer|Long|Number|String)|org\.apache\.catalina\.filters\.CsrfPreventionFilter\$LruCache(?:\$1)?|java\.util\.(?:Linked)?HashMap"/>
</Context>
EOF
  }

getHostContextData() {
    cat << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<Context antiResourceLocking="false" privileged="true" >
  <CookieProcessor className="org.apache.tomcat.util.http.Rfc6265CookieProcessor"
                   sameSiteCookies="strict" />
  <!-- <Valve className="org.apache.catalina.valves.RemoteAddrValve"
         allow="127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1" /> -->
  <Manager sessionAttributeValueClassNameFilter="java\.lang\.(?:Boolean|Integer|Long|Number|String)|org\.apache\.catalina\.filters\.CsrfPreventionFilter\$LruCache(?:\$1)?|java\.util\.(?:Linked)?HashMap"/>
</Context>
EOF
  }

tomcat_users_file_path="/opt/tomcat/conf/tomcat-users.xml"
tomcat_manager_context_path="/opt/tomcat/webapps/manager/META-INF/context.xml"
tomcat_host_context_path="/opt/tomcat/webapps/host-manager/META-INF/context.xml"

getTomcatUserConfig > "$tomcat_users_file_path"
execute_command "--- updated file $tomcat_users_file_path ---"

getManagerContextData > "$tomcat_manager_context_path"
execute_command "--- updated file $tomcat_manager_context_path ---"

getHostContextData > "$tomcat_host_context_path"
execute_command "--- updated file $tomcat_host_context_path ---"

execute_command "---- Creating a Tomcat service ----" ""

create_tomcat_service() {
  cat << 'EOF'
[Unit]
Description=Tomcat
After=network.target

[Service]
Type=forking

User=tomcat
Group=tomcat

Environment="JAVA_HOME=/usr/lib/jvm/java-1.17.0-openjdk-amd64"
Environment="JAVA_OPTS=-Djava.security.egd=file:///dev/urandom"
Environment="CATALINA_BASE=/opt/tomcat"
Environment="CATALINA_HOME=/opt/tomcat"
Environment="CATALINA_PID=/opt/tomcat/temp/tomcat.pid"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOF
}

tomcat_service_path="/etc/systemd/system/tomcat.service"
create_tomcat_service | sudo tee "$tomcat_service_path" > /dev/null

execute_command "---- Reloading system ----" "systemctl daemon-reload"
execute_command "---- Enable Tomcat Service ---- " "sudo systemctl enable tomcat"
execute_command "---- Enable port 8080 ---- " "sudo ufw allow 8080"
execute_command "---- Creating git directory ---- " "mkdir /git"
#execute_command "---- Cloning sample tomcat application ---- " "git clone https://${git_user}:${git_password}@git-codecommit.us-east-1.amazonaws.com/v1/repos/sample-tomcat-application /git/sample-tomcat-application"
execute_command "---- Cloning sample tomcat application ---- " "git clone https://rahulraju-at-590184127533:i17m0V0sPpGNqVqk+YbXeesSXkbA+koY/H80rNWYB7WsYVSPgT+8Z2uD3x8=@git-codecommit.us-east-1.amazonaws.com/v1/repos/sample-tomcat-application /git/sample-tomcat-application"
execute_command "---- Performing build operation... ---- " "cd /git/sample-tomcat-application/ && mvn clean package"
execute_command "---- Copying war file to tomcat webapps ---- " "cp /git/sample-tomcat-application/target/sample-tomcat-application.war /opt/tomcat/webapps/"

assign_aws_env_props() {
    cat << EOF
export CATALINA_OPTS="-Daws.accessKeyId='${aws_access_key}' -Daws.secretKey='${aws_secret_key}'"
EOF
}

tomcat_set_env_path="/opt/tomcat/bin/setenv.sh"
assign_aws_env_props > "$tomcat_set_env_path"
execute_command "---- Created file $tomcat_set_env_path ---- " ""
execute_command "---- Assigning permission for executing $tomcat_set_env_path ---- " "chmod g+wx '$tomcat_set_env_path'"
execute_command "---- Starting Tomcat service ----" "sudo systemctl start tomcat"
execute_command "---- checking tomcat server status ---" "sudo systemctl status tomcat"