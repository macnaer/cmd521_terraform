output "instance_public_ip_primary" {
  description = "Public IP address of the primary EC2 instance"
  value       = aws_instance.primary.public_ip
}

output "instance_public_ip_secondary" {
  description = "Public IP address of the secondary EC2 instance"
  value       = aws_instance.secondary.public_ip
}

output "security_group_id" {
  description = "ID of the Terraform security group"
  value       = aws_security_group.this.id
}
