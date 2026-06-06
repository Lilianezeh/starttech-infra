#!/bin/bash
set -e

echo "Deploying StartTech Infrastructure..."

cd terraform

terraform init
terraform validate
terraform plan -var="mongo_uri=$MONGO_URI" -var="jwt_secret=$JWT_SECRET"
terraform apply -auto-approve -var="mongo_uri=$MONGO_URI" -var="jwt_secret=$JWT_SECRET"

echo "Infrastructure deployed successfully!"
terraform output