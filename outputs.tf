output "instance_id" {
  description = "AMI ID of Ubuntu instance"
  value       = data.aws_ami.amiID.id
}

output "vpc_id" {
  description = "VPC ID of our custom vpc"
  value       = module.vpc.vpc_id
}

output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "haproxy_private_ip" {
  value = aws_instance.haproxy.private_ip
}

output "web_private_ips" {
  description = "Private IPs of web servers"
  value       = aws_instance.web[*].private_ip
}
