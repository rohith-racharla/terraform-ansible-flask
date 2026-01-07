output "instance_id" {
  description = "AMI ID of Ubuntu instance"
  value       = data.aws_ami.amiID.id
}

output "vpc_id" {
  description = "VPC ID of our custom vpc"
  value       = module.vpc.vpc_id
}
