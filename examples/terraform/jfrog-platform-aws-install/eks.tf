# This file is used to create an AWS EKS cluster and the managed node group(s)

locals {
    cluster_name = "${var.env_name}-eks-cluster"
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

module "eks" {
    source  = "terraform-aws-modules/eks/aws"
    version = "~> 20.0"

    cluster_name    = local.cluster_name
    cluster_version = var.kubernetes_version

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
        ami_type = var.ami_type
        iam_role_additional_policies = {
            AmazonS3FullAccess       = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
            AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        }
        pre_bootstrap_user_data = <<-EOF
        # This script will run on all nodes before the kubelet starts
        echo "It works!" > /tmp/pre_bootstrap_user_data.txt
        EOF
        block_device_mappings = {
            xvda = {
                device_name = "/dev/xvda"
                ebs = {
                    volume_type           = "gp3"
                    volume_size           = var.eks_root_volume_size
                    throughput            = var.eks_root_throughput
                    delete_on_termination = true
                }
            }
        }
        tags = {
            Group = var.common_tag
            Env   = var.env_name
        }
    }

    eks_managed_node_groups = {
        artifactory = {
            name = "${var.env_name}-artifactory"

            instance_types = [local.s.artifactory_instance]
            min_size       = 1
            max_size       = 10
            desired_size   = local.s.artifactory_desired

            block_device_mappings = {
                xvda = {
                    device_name = "/dev/xvda"
                    ebs = {
                        volume_type           = "gp3"
                        volume_size           = local.s.artifactory_disk_size
                        iops                  = local.s.artifactory_disk_iops
                        throughput            = local.s.artifactory_disk_throughput
                        delete_on_termination = true
                    }
                }
            }
            labels = {
                "group" = "artifactory"
                "env"   = var.env_name
            }
        }

        nginx = {
            name = "${var.env_name}-nginx"

            instance_types = [local.s.nginx_instance]
            min_size       = 1
            max_size       = 10
            desired_size   = local.s.nginx_desired

            labels = {
                "group" = "nginx"
                "env"   = var.env_name
            }
        }

        xray = {
            name = "${var.env_name}-xray"

            instance_types = [local.s.xray_instance]
            min_size       = 1
            max_size       = 10
            desired_size   = local.s.xray_desired

            block_device_mappings = {
                xvda = {
                    device_name = "/dev/xvda"
                    ebs = {
                        volume_type           = "gp3"
                        volume_size           = local.s.xray_disk_size
                        iops                  = local.s.xray_disk_iops
                        throughput            = local.s.xray_disk_throughput
                        delete_on_termination = true
                    }
                }
            }
            labels = {
                "group" = "xray"
                "env"   = var.env_name
            }
        }

        ## Create an extra node group for testing
        extra = {
            name = "${var.env_name}-extra"

            instance_types = [var.extra_node_size]
            min_size       = 0
            max_size       = 3
            desired_size   = var.extra_node_count

            labels = {
                "group" = "extra"
                "env"   = var.env_name
            }
        }
    }

    tags = {
        Group = var.common_tag
        Env   = var.env_name
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
    storage_provisioner    = "ebs.csi.aws.com"
    volume_binding_mode    = "WaitForFirstConsumer"
    allow_volume_expansion = true
    parameters = {
        "fsType" = "ext4"
        "type"   = "gp3"
    }
}

module "ebs_csi_irsa_role" {
    source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
    version = "~> 5.0"

    role_name             = "ebs-csi-${module.eks.cluster_name}-${var.region}"
    attach_ebs_csi_policy = true

    oidc_providers = {
        ex = {
            provider_arn               = module.eks.oidc_provider_arn
            namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
        }
    }
}
