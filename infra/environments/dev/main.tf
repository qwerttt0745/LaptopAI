module "vpc" {
  source = "../../modules/vpc"

  env        = "dev"
  aws_region = var.aws_region
}

module "ec2" {
  source = "../../modules/ec2-k3s"

  env              = "dev"
  vpc_id           = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnet_id
  instance_type    = var.instance_type
}

module "rds" {
  source = "../../modules/rds"

  env                = "dev"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  ec2_sg_id          = module.ec2.security_group_id
  db_password        = var.db_password
}