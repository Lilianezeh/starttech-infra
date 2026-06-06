variable "aws_region" {
  default = "us-east-1"
}

variable "project_name" {
  default = "starttech"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "ami_id" {
  description = "Ubuntu 22.04 AMI for us-east-1"
  default     = "ami-00403f401ee6a4b98"
}

variable "mongo_uri" {
  description = "MongoDB Atlas connection string"
  sensitive   = true
}

variable "jwt_secret" {
  description = "JWT secret key"
  sensitive   = true
  default     = "StartTechJWTSecret2024"
}

variable "ecr_image_uri" {
  description = "ECR image URI for backend"
  default     = ""
}