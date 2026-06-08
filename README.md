# StartTech Infrastructure

## Overview
Terraform infrastructure for StartTech application on AWS.

## Architecture
- **VPC**: Custom VPC with public and private subnets across 2 AZs
- **Backend**: EC2 Auto Scaling Group behind ALB
- **Frontend**: S3 static website with CloudFront CDN
- **Cache**: ElastiCache Redis
- **Monitoring**: CloudWatch Logs and Alarms

## Infrastructure Details
| Resource | Value |
|---|---|
| ALB DNS | `starttech-alb-9595592.us-east-1.elb.amazonaws.com` |
| S3 Bucket | `starttech-frontend-bucket-4944d90c` |
| Redis | `starttech-redis.uinypn.0001.use1.cache.amazonaws.com` |
| Log Group | `/starttech/backend` |

## Deployment

### Prerequisites
- Terraform installed
- AWS CLI configured
- MongoDB Atlas URI

### Deploy
```bash
cd terraform
terraform init
terraform plan -var="mongo_uri=YOUR_URI" -var="jwt_secret=YOUR_SECRET"
terraform apply -auto-approve -var="mongo_uri=YOUR_URI" -var="jwt_secret=YOUR_SECRET"
```

### Destroy
```bash
terraform destroy -auto-approve -var="mongo_uri=YOUR_URI" -var="jwt_secret=YOUR_SECRET"
```

## Required GitHub Secrets
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_REGION
MONGO_URI
JWT_SECRET

## Modules
- **networking**: VPC, subnets, security groups, NAT gateway
- **compute**: ALB, ASG, Launch Template, ElastiCache
- **storage**: S3 bucket, CloudFront distribution
- **monitoring**: CloudWatch log groups and alarms
# trigger workflow
# Infrastructure deployment automated via GitHub Actions
