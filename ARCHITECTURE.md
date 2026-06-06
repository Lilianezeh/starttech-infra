# StartTech Infrastructure Architecture

## Overview
All infrastructure is managed with Terraform using modular design.

## Terraform Modules

### networking/
- VPC with DNS support
- Public and private subnets across 2 AZs
- Internet Gateway and NAT Gateway
- Security Groups for ALB, Backend, Redis

### compute/
- Application Load Balancer
- Launch Template with user data
- Auto Scaling Group (min:1, max:3)
- ElastiCache Redis cluster
- IAM roles for EC2

### storage/
- S3 bucket for frontend hosting
- Static website configuration
- Public access policy
- CloudFront distribution (pending account verification)

### monitoring/
- CloudWatch Log Groups
- CPU utilization alarms
- ASG scaling triggers

## Infrastructure Details
| Resource | Value |
|---|---|
| VPC CIDR | 10.0.0.0/16 |
| ALB DNS | starttech-alb-9595592.us-east-1.elb.amazonaws.com |
| S3 Bucket | starttech-frontend-bucket-4944d90c |
| Redis | starttech-redis.uinypn.0001.use1.cache.amazonaws.com |
| Log Group | /starttech/backend |

## Security Design
- EC2 instances in private subnets only
- ALB accepts traffic on port 80/443
- Backend accepts traffic only from ALB
- Redis accepts traffic only from backend
- NAT Gateway for outbound internet access