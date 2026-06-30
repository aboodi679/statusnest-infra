module "vpc" {
  source = "./modules/vpc"

  environment           = var.environment
  vpc_cidr              = "10.0.0.0/16"
  availability_zones    = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs  = ["10.0.11.0/24", "10.0.12.0/24"]
}

module "aurora" {
  source = "./modules/aurora"

  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  vpc_cidr           = module.vpc.vpc_cidr
}
module "elasticache" {
  source = "./modules/elasticache"

  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  vpc_cidr           = module.vpc.vpc_cidr
}