resource "aws_instance" "ec2_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name = var.instance_name
  }
  vpc_security_group_ids      = var.security_group_ids
  key_name                    = aws_key_pair.ec2_key_pair.key_name
  #  user_data = templatefile("./aws_ec2_instance/script/deploy.sh", {
  #  git_user = var.git_user, git_password = var.git_password
  #  aws_access_key = var.aws_access_key, aws_secret_key = var.aws_secret_key
  #  })
  subnet_id                   = var.allocate_subnet_id
  associate_public_ip_address = var.associate_public_ip_address
}

resource "aws_key_pair" "ec2_key_pair" {
  key_name   = var.key_pair_name
  public_key = file("./ssh_keys/ssh_ec2_kp_1.pub")
}
