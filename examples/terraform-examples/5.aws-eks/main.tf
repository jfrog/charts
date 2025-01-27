# This file is used to create an
# AWS VPC and EKS cluster with a managed node group
# It also creates a gp3 storage class and makes it the default

data "aws_eks_cluster_auth" "jfrog_cluster" {
    name = module.eks.cluster_name
}

data "aws_availability_zones" "available" {
    filter {
        name   = "opt-in-status"
        values = ["opt-in-not-required"]
    }
}

locals {
    cluster_name = var.cluster_name
}

resource "aws_security_group_rule" "allow_management_from_my_ip" {
    type              = "ingress"
    from_port         = 0
    to_port           = 65535
    protocol          = "-1"
    cidr_blocks       = var.cluster_public_access_cidrs
    security_group_id = module.eks.cluster_security_group_id
    description       = "Allow all traffic from my public IP for management"
}

module "vpc" {
    source  = "terraform-aws-modules/vpc/aws"

    name = "demo-vpc"

    cidr = "10.0.0.0/16"
    azs  = slice(data.aws_availability_zones.available.names, 0, 3)

    private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

    enable_nat_gateway   = true
    single_nat_gateway   = true
    enable_dns_hostnames = true

    public_subnet_tags = {
        "kubernetes.io/role/elb" = 1
    }

    private_subnet_tags = {
        "kubernetes.io/role/internal-elb" = 1
    }
}

module "eks" {
    source  = "terraform-aws-modules/eks/aws"

    cluster_name    = local.cluster_name
    cluster_version = "1.31"

    enable_cluster_creator_admin_permissions = true
    cluster_endpoint_public_access           = true
    cluster_endpoint_public_access_cidrs     = var.cluster_public_access_cidrs

    cluster_addons = {
        aws-ebs-csi-driver = {
            most_recent = true
            service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn
        }
    }

    vpc_id     = module.vpc.vpc_id
    subnet_ids = module.vpc.private_subnets

    eks_managed_node_group_defaults = {
        ami_type = "AL2_ARM_64"
        iam_role_additional_policies = {
            AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        }

        pre_bootstrap_user_data = <<-EOF
        # This script will run on all nodes before the kubelet starts
        echo "It works!" > /tmp/pre_bootstrap_user_data.txt
        EOF
    }

    eks_managed_node_groups = {
        one = {
            name = "node-group-1"

            instance_types = ["t4g.small"]

            min_size     = 1
            max_size     = var.pool_max_size
            desired_size = var.pool_desired_size
        }

        # two = {
        #     name = "node-group-2"
        #
        #     instance_types = ["t3.small"]
        #
        #     min_size     = 1
        #     max_size     = 2
        #     desired_size = 1
        # }
    }
}

# Create the gp3 storage class and make it the default
resource "kubernetes_storage_class" "gp3_storage_class" {
    metadata {
        name = "gp3"
        annotations = {
            "storageclass.kubernetes.io/is-default-class" = "true"
        }
    }
    storage_provisioner = "ebs.csi.aws.com"
    volume_binding_mode = "WaitForFirstConsumer"
    allow_volume_expansion = true
    parameters = {
        "fsType" = "ext4"
        "type" = "gp3"
    }
}

module "ebs_csi_irsa_role" {
    source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

    role_name             = "ebs-csi-${module.eks.cluster_name}"
    attach_ebs_csi_policy = true

    oidc_providers = {
        ex = {
            provider_arn               = module.eks.oidc_provider_arn
            namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
        }
    }
}
