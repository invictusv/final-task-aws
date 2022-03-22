output "vpc_id" {
  value = module.vpc.vpc_id
}

output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value = module.ec2_instance.public_ip
}