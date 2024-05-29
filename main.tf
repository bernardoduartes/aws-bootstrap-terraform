module "vpc" {
    source = "./modules/vpc"
    app_name = var.app_name
    vpc_cidr_block = var.vpc_cidr_block
}

module "eks" {
    source = "./modules/eks"
    app_name = var.app_name
    vpc_id = module.vpc.vpc_id
    cluster_name = var.cluster_name
    log_retention_day = var.log_retention_day
    subnets_ids = module.vpc.subnets_ids
    min_size = var.min_size
    max_size = var.max_size
    desired_size = var.desired_size
}