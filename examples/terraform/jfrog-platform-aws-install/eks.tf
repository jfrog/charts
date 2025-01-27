# This file is used to create an AWS EKS cluster and the managed node group(s)

locals {
    cluster_name = "${var.cluster_name}-${random_pet.unique_name.id}"
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
            AmazonS3FullAccess = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
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
                    volume_type = "gp3"
                    volume_size = 50
                    throughput  = 125
                    delete_on_termination = true
                }
            }
        }
        tags = {
            Group = var.common_tag
        }
    }

    eks_managed_node_groups = {
        artifactory = {
            name = "artifactory-node-group"

            instance_types = [(
                var.sizing == "large"   ? var.artifactory_node_size_large :
                var.sizing == "xlarge"  ? var.artifactory_node_size_large :
                var.sizing == "2xlarge" ? var.artifactory_node_size_large :
                var.artifactory_node_size_default
            )]
            min_size     = 1
            max_size     = 10
            desired_size = (
                var.sizing == "medium"  ? 2 :
                var.sizing == "large"   ? 3 :
                var.sizing == "xlarge"  ? 4 :
                var.sizing == "2xlarge" ? 6 :
                1
            )
            block_device_mappings = {
                xvda = {
                    device_name = "/dev/xvda"
                    ebs = {
                        volume_type = "gp3"
                        volume_size = (
                            var.sizing == "large"   ? var.artifactory_disk_size_large :
                            var.sizing == "xlarge"  ? var.artifactory_disk_size_large :
                            var.sizing == "2xlarge" ? var.artifactory_disk_size_large :
                            var.artifactory_disk_size_default
                        )
                        iops = (
                            var.sizing == "large"   ? var.artifactory_disk_iops_large :
                            var.sizing == "xlarge"  ? var.artifactory_disk_iops_large :
                            var.sizing == "2xlarge" ? var.artifactory_disk_iops_large :
                            var.artifactory_disk_iops_default
                        )
                        throughput = (
                            var.sizing == "large"   ? var.artifactory_disk_throughput_large :
                            var.sizing == "xlarge"  ? var.artifactory_disk_throughput_large :
                            var.sizing == "2xlarge" ? var.artifactory_disk_throughput_large :
                            var.artifactory_disk_throughput_default
                        )
                        delete_on_termination = true
                    }
                }
            }
            labels = {
                "group" = "artifactory"
            }
        }

        nginx = {
            name = "nginx-node-group"

            instance_types = [(
                var.sizing == "xlarge"  ? var.nginx_node_size_large :
                var.sizing == "2xlarge" ? var.nginx_node_size_large :
                var.nginx_node_size_default
            )]

            min_size     = 1
            max_size     = 10
            desired_size = (
                var.sizing == "medium"  ? 2 :
                var.sizing == "large"   ? 2 :
                var.sizing == "xlarge"  ? 2 :
                var.sizing == "2xlarge" ? 3 :
                1
            )

            labels = {
                "group" = "nginx"
            }
        }

        xray = {
            name = "xray-node-group"

            instance_types = [(
                var.sizing == "xlarge"  ? var.xray_node_size_xlarge :
                var.sizing == "2xlarge" ? var.xray_node_size_xlarge :
                var.xray_node_size_default
            )]
            min_size     = 1
            max_size     = 10
            desired_size = (
                var.sizing == "medium"  ? 2 :
                var.sizing == "large"   ? 3 :
                var.sizing == "xlarge"  ? 4 :
                var.sizing == "2xlarge" ? 6 :
                1
            )
            block_device_mappings = {
                xvda = {
                    device_name = "/dev/xvda"
                    ebs = {
                        volume_type = "gp3"
                        volume_size = (
                            var.sizing == "large"   ? var.xray_disk_size_large :
                            var.sizing == "xlarge"  ? var.xray_disk_size_large :
                            var.sizing == "2xlarge" ? var.xray_disk_size_large :
                            var.xray_disk_size_default
                        )
                        iops = (
                            var.sizing == "large"   ? var.xray_disk_iops_large :
                            var.sizing == "xlarge"  ? var.xray_disk_iops_large :
                            var.sizing == "2xlarge" ? var.xray_disk_iops_large :
                            var.xray_disk_iops_default
                        )
                        throughput = (
                            var.sizing == "large"   ? var.xray_disk_throughput_large :
                            var.sizing == "xlarge"  ? var.xray_disk_throughput_large :
                            var.sizing == "2xlarge" ? var.xray_disk_throughput_large :
                            var.xray_disk_throughput_default
                        )
                        delete_on_termination = true
                    }
                }
            }
            labels = {
                "group" = "xray"
            }
        }

        ## Create an extra node group for testing
        extra = {
            name = "extra-node-group"

            instance_types = [var.extra_node_size]

            min_size     = 1
            max_size     = 3
            desired_size = var.extra_node_count

            labels = {
                "group" = "extra"
            }
        }
    }

    tags = {
        Group = var.common_tag
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

    role_name             = "ebs-csi-${module.eks.cluster_name}-${var.region}"
    attach_ebs_csi_policy = true

    oidc_providers = {
        ex = {
            provider_arn               = module.eks.oidc_provider_arn
            namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
        }
    }
}
