provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_instance" "EC2_instance" {
  ami           = var.aws_image_id
  instance_type = var.aws_instance_type
  key_name      = var.aws_key_name
  user_data     = file("${path.module}/files/install.sh")

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 20
    volume_type = "gp3"
    tags = {
      Name = "RootVolume"
    }
  }

  tags = {
    Name = "Demo Instance"
  }

  vpc_security_group_ids = [aws_security_group.SG_Terrafrom.id]
}

resource "aws_security_group" "SG_Terrafrom" {
  name        = "SG_Terraform"
  description = "Security group for Terraform demo"
}

resource "aws_security_group_rule" "ingress_rule" {
  for_each = {
    "ssh"  = { from_port = 22, to_port = 22, protocol = "tcp", description = "SSH access" }
    "http" = { from_port = 80, to_port = 80, protocol = "tcp", description = "HTTP access" }
    "icmp" = { from_port = -1, to_port = -1, protocol = "icmp", description = "ICMP ping" }
  }
  type              = "ingress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = ["0.0.0.0/0"]
  description       = each.value.description
  security_group_id = aws_security_group.SG_Terrafrom.id
}

resource "aws_security_group_rule" "egress_rule" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.SG_Terrafrom.id
}
