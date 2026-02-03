module "vpc" {
  source = "./modules/vpc"
  cidr_vpc = var.vpc_cidr
  cidr_private = var.private_subnets_cidr
  public_subnet_cidr  =  var.public_subnets_cidr
  name_private = var.private_subnets_names
  name_public =  var.public_subnets_names
  vpc_name   =  var.vpc_name
  igw = var.igw_name
}

module "ec2" {
  source = "./modules/ec2"
  subnet_id = module.vpc.public_subnet_id
  public_ip_or_not = true
  ami = "ami-073130f74f5ffb161"
  volume_size = "30"
  key_name = "ash2"
  instance_type = ["m7i-flex.large"]
  security_group_ids = [module.sg.sg_id]
  ec2_names = ["agent"]
}

module "sg" {
  source = "./modules/security_group"
  vpc_id = module.vpc.vpc_id
  vpc_cidr = var.vpc_cidr
}

module "eks" {
  source = "./modules/eks"
  eks_subnets_ids = module.vpc.private_subnet_id
  eks_nodes_subnets_ids =  module.vpc.private_subnet_id
  security_group_ids = [module.sg.sg_id]
  enable_private_access = true
  enable_public_access =  true
  nodes_ec2_type  = ["c7i-flex.large"]
  node_group_name = "eks_nodes"
  max_nodes = 5
  min_nodes = 3
  desired_nodes = 3
  k8s_version = "1.29"
  cluster_name = "test"
}

module "ecr" {
  source = "./modules/ecr"
  ecr_name = "tetris-repo"
}
