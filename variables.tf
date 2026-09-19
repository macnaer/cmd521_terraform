variable "aws_access_key" {
  description = "AWS access key for authentication"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS secret key for authentication"
  type        = string
  sensitive   = true
}

variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "eu-north-1"
}

variable "aws_zone" {
  description = "AWS availability zone"
  type        = string
  default     = "eu-north-1a"
}

variable "aws_image_id" {
  description = "AMI ID for the primary Ubuntu EC2 instance"
  type        = string
  default     = "ami-0aba19e56f3eaec05"
}

variable "aws_image_id_2" {
  description = "AMI ID for the secondary Amazon Linux EC2 instance"
  type        = string
  default     = "ami-07b8fb6bd3e9627a6"
}

variable "aws_instance_type" {
  description = "EC2 instance type for both instances"
  type        = string
  default     = "t3.small"
}

variable "aws_key_name" {
  description = "Name of the existing EC2 key pair for SSH access"
  type        = string
  default     = "Stockholm_3"
}

variable "s3_bucket_name" {
  description = "Globally unique name for the S3 static website bucket"
  type        = string
  default     = "terraform-static-website-eu-north-1"
}

variable "s3_force_destroy" {
  description = "Allow Terraform to delete the S3 bucket even if it contains objects"
  type        = bool
  default     = true
}

variable "s3_versioning_enabled" {
  description = "Enable versioning on the S3 bucket"
  type        = bool
  default     = true
}

variable "s3_website_index_document" {
  description = "Index document for the S3 static website"
  type        = string
  default     = "index.html"
}

variable "s3_website_error_document" {
  description = "Error document for the S3 static website"
  type        = string
  default     = "error.html"
}

variable "common_tags" {
  description = "Tags applied to every resource that supports tagging"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
    Project   = "CMD521"
  }
}
