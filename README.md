# Terraform AWS EC2 Demo

![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.0-purple)
![AWS](https://img.shields.io/badge/AWS-EC2-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## Overview

Deploys an Ubuntu EC2 instance in AWS Stockholm (`eu-north-1`) with Apache2
web server provisioned via `user_data`.

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                    AWS eu-north-1                    │
│                                                     │
│  ┌───────────────────────────────────────────────┐  │
│  │              Security Group                   │  │
│  │  Ingress:  SSH (22)  │ HTTP (80) │ ICMP       │  │
│  │  Egress:   All traffic                        │  │
│  │                                               │  │
│  │  ┌─────────────────────────────────────────┐  │  │
│  │  │          EC2 Instance (t3.small)        │  │  │
│  │  │  Ubuntu │ 20GB gp3 │ Key: Stockholm_3   │  │  │
│  │  │                                         │  │  │
│  │  │  user_data → install.sh → Apache2       │  │  │
│  │  └─────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured (`aws configure`)
- AWS account with EC2 permissions

## Quick Start

```bash
# 1. Clone the repository
git clone <repo-url> && cd Terraform

# 2. Create credentials file
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your AWS keys

# 3. Initialize and apply
terraform init
terraform plan
terraform apply
```

## Project Structure

| File | Description |
|------|-------------|
| `main.tf` | Provider config, EC2 instance, Security Group, SG rules |
| `vars.tf` | Variable declarations (credentials marked `sensitive`) |
| `outputs.tf` | Public IP of the EC2 instance |
| `terraform.tfvars` | Real AWS credentials (gitignored) |
| `terraform.tfvars.example` | Template for credentials |
| `files/install.sh` | Apache2 provisioning script |
| `opencode.json` | OpenCode skill configuration |
| `.opencode/skills/` | Cloud DevOps Architect skill |

## Variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `aws_access_key` | string | — | AWS access key (sensitive) |
| `aws_secret_key` | string | — | AWS secret key (sensitive) |
| `aws_region` | string | `eu-north-1` | AWS region |
| `aws_image_id` | string | `ami-0aba...` | Ubuntu AMI ID |
| `aws_instance_type` | string | `t3.small` | EC2 instance type |
| `aws_key_name` | string | `Stockholm_3` | SSH key pair name |

## Outputs

| Name | Description |
|------|-------------|
| `instance_public_ip` | Public IP of the EC2 instance |

## Commands

```bash
terraform init      # Initialize providers
terraform plan      # Preview changes
terraform apply     # Apply changes
terraform destroy   # Tear down infrastructure
terraform fmt       # Format code
terraform validate  # Validate syntax
```

## Security

- AWS credentials stored in `terraform.tfvars` (gitignored)
- Variables marked `sensitive = true` to prevent output leakage
- See [Security Guidelines](.opencode/skills/cloud-devops-architect/references/security-guidelines.md)
