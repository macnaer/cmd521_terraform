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
  type    = string
  default = "eu-north-1"
}

variable "aws_zone" {
  type    = string
  default = "eu-north-1a"
}

variable "aws_image_id" {
  type    = string
  default = "ami-0aba19e56f3eaec05"
}

variable "aws_instance_type" {
  type    = string
  default = "t3.small"
}

variable "aws_key_name" {
  type    = string
  default = "Stockholm_3"
}
