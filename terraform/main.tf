terraform {
  backend "s3" {
    bucket         = "starttech-terraform-state-4944d90c"
    key            = "starttech/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }

  required_providers {
    aws    = { source = "hashicorp/aws", version = "~> 5.0" }
    random = { source = "hashicorp/random", version = "~> 3.0" }
  }
}

provider "aws" {
  region = var.aws_region
}

module "networking" {
  source       = "./modules/networking"
  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
  aws_region   = var.aws_region
}

module "storage" {
  source       = "./modules/storage"
  project_name = var.project_name
  aws_region   = var.aws_region
}

module "compute" {
  source           = "./modules/compute"
  project_name     = var.project_name
  vpc_id           = module.networking.vpc_id
  public_subnet_1  = module.networking.public_subnet_1
  public_subnet_2  = module.networking.public_subnet_2
  private_subnet_1 = module.networking.private_subnet_1
  private_subnet_2 = module.networking.private_subnet_2
  alb_sg_id        = module.networking.alb_sg_id
  backend_sg_id    = module.networking.backend_sg_id
  redis_sg_id      = module.networking.redis_sg_id
  ami_id           = var.ami_id
  instance_type    = var.instance_type
  mongo_uri        = var.mongo_uri
  jwt_secret       = var.jwt_secret
  ecr_image_uri    = var.ecr_image_uri
}

module "monitoring" {
  source       = "./modules/monitoring"
  project_name = var.project_name
  asg_name     = module.compute.asg_name
  alb_arn      = module.compute.alb_arn
}