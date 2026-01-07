resource "aws_instance" "bastion" {
  ami           = data.aws_ami.amiID.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.sshkeypair.key_name

  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "bastion"
  }
}

resource "aws_instance" "haproxy" {
  ami           = data.aws_ami.amiID.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.sshkeypair.key_name

  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.haproxy_sg.id]

  tags = {
    Name = "haproxy"
  }
}

resource "aws_instance" "web" {
  count         = var.web_count
  ami           = data.aws_ami.amiID.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.sshkeypair.key_name

  subnet_id              = module.vpc.private_subnets[0]
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "web${count.index + 1}"
  }
}
