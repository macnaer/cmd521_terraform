variable "aws_image_id" {
  description = "AMI ID for the primary Ubuntu instance"
  type        = string
}

variable "aws_image_id_2" {
  description = "AMI ID for the secondary Amazon Linux instance"
  type        = string
}

variable "aws_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "aws_key_name" {
  description = "Name of the EC2 key pair for SSH access"
  type        = string
}

variable "tags" {
  description = "Common tags applied to all EC2 resources"
  type        = map(string)
  default     = { ManagedBy = "Terraform" }
}
