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
module "alb" {
  source            = "./modules/alb"
  environment       = "dev"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
}
module "ecs" {
  source                = "./modules/ecs"
  environment           = "dev"
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  alb_security_group_id = module.alb.alb_security_group_id
  db_url_secret_arn  = module.secrets.db_url_secret_arn
  smtp_secret_arn       = module.secrets.smtp_secret_arn
  webhook_secret_arn    = module.secrets.webhook_secret_arn
  jwt_secret_arn        = module.secrets.jwt_secret_arn
  ecr_image_url         = "026243800492.dkr.ecr.us-east-1.amazonaws.com/statusnest-dev-auth:latest"
  alb_target_group_arn  = module.alb.auth_target_group_arn
  redis_url = "redis://statusnest-dev-redis.b8x2ra.0001.use1.cache.amazonaws.com:6379"
}
module "secrets" {
  source      = "./modules/secrets"
  environment = "dev"
}
module "oidc" {
  source      = "./modules/oidc"
  environment = "dev"
}
module "bastion" {
  source             = "./modules/bastion"
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
}
module "ecr" {
  source      = "./modules/ecr"
  environment = "dev"
}
module "notifications" {
  source      = "./modules/notifications"
  environment = var.environment
  alert_email = "aaboodi679@gmail.com"
}
module "frontend" {
  source      = "./modules/frontend"
  environment = var.environment
}