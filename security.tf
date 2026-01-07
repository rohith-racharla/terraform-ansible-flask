########## BASTION ##########
resource "aws_security_group" "bastion_sg" {
  name        = "bastion_sg"
  description = "Security group for Bastion host"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "SSHfromMyIP" {
  security_group_id = aws_security_group.bastion_sg.id
  description       = "Allow SSH access from my IP only"
  cidr_ipv4         = var.myIP
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "bastion_sg_to_web_sg" {
  security_group_id            = aws_security_group.bastion_sg.id
  description                  = "Allow SSH traffic from bastion sg to web sg "
  referenced_security_group_id = aws_security_group.web_sg.id
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "bastion_sg_to_haproxy_sg" {
  security_group_id            = aws_security_group.bastion_sg.id
  description                  = "Allow SSH traffic from bastion sg to haproxy sg"
  referenced_security_group_id = aws_security_group.haproxy_sg.id
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
}


########## HAProxy ##########
resource "aws_security_group" "haproxy_sg" {
  name        = "haproxy_sg"
  description = "Security group for HAProxy server"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "allowHTTP" {
  security_group_id = aws_security_group.haproxy_sg.id
  description       = "Allow HTTP traffic to HAProxy"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "allow_SSH_from_bastion_sg_to_haproxy_sg" {
  security_group_id            = aws_security_group.haproxy_sg.id
  description                  = "Allow SSH access from Bastion host to HAProxy server"
  referenced_security_group_id = aws_security_group.bastion_sg.id
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outboundIPv4_from_haproxy_sg" {
  security_group_id = aws_security_group.haproxy_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" #Semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outboundIPv6_from_haproxy_sg" {
  security_group_id = aws_security_group.haproxy_sg.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" #Semantically equivalent to all ports
}


########## Web Servers ##########
resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Security group for Web servers"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "allow_SSH_from_bastion_sg_to_web_sg" {
  security_group_id            = aws_security_group.web_sg.id
  description                  = "Allow SSH access from Bastion host to Web servers"
  referenced_security_group_id = aws_security_group.bastion_sg.id
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "haproxy_sg_to_web_sg" {
  security_group_id            = aws_security_group.web_sg.id
  description                  = "Allow traffic from HAProxy sg to Web Servers"
  referenced_security_group_id = aws_security_group.haproxy_sg.id
  from_port                    = 5000
  to_port                      = 5000
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outboundIPv4_from_web_sg" {
  security_group_id = aws_security_group.web_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" #Semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outboundIPv6_from_web_sg" {
  security_group_id = aws_security_group.web_sg.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" #Semantically equivalent to all ports
}
