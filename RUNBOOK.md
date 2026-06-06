# StartTech Infrastructure Runbook

## Deployment

### Full Infrastructure Deploy
```bash
cd terraform
terraform init
terraform plan -var="mongo_uri=$MONGO_URI" -var="jwt_secret=$JWT_SECRET"
terraform apply -auto-approve -var="mongo_uri=$MONGO_URI" -var="jwt_secret=$JWT_SECRET"
```

### Destroy Infrastructure
```bash
terraform destroy -auto-approve -var="mongo_uri=$MONGO_URI" -var="jwt_secret=$JWT_SECRET"
```

## Scaling

### Manual Scale Up
```bash
aws autoscaling set-desired-capacity \
  --auto-scaling-group-name starttech-asg \
  --desired-capacity 2
```

### Manual Scale Down
```bash
aws autoscaling set-desired-capacity \
  --auto-scaling-group-name starttech-asg \
  --desired-capacity 1
```

## Monitoring

### View Logs
```bash
aws logs tail /starttech/backend --follow
```

### Check ALB Health
```bash
aws elbv2 describe-target-health \
  --target-group-arn $(aws elbv2 describe-target-groups \
  --query "TargetGroups[?contains(TargetGroupName,'starttech')].TargetGroupArn" \
  --output text)
```

## Troubleshooting

### EC2 Not Joining ASG
1. Check Launch Template user data
2. Verify security groups allow traffic
3. Check IAM instance profile permissions

### Redis Connection Failed
1. Verify security group allows port 6379 from backend
2. Check Redis endpoint in terraform output
3. Verify REDIS_ADDR environment variable on EC2