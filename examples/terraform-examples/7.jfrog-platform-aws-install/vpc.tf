# This file is used to create the AWS VPC

data "aws_availability_zones" "available" {
    filter {
        name   = "opt-in-status"
        values = ["opt-in-not-required"]
    }
}

module "vpc" {
    source  = "terraform-aws-modules/vpc/aws"

    name = "jfrog-vpc"

    cidr = var.vpc_cidr
    azs  = slice(data.aws_availability_zones.available.names, 0, 3)

    private_subnets = var.private_subnet_cidrs
    public_subnets  = var.public_subnet_cidrs

    enable_nat_gateway   = true
    single_nat_gateway   = true
    enable_dns_hostnames = true

    public_subnet_tags = {
        "kubernetes.io/role/elb" = 1
    }

    private_subnet_tags = {
        "kubernetes.io/role/internal-elb" = 1
    }

    tags = {
        Group = var.common_tag
    }
}
