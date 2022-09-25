module "eks_cluster" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.10.0"

  cluster_name       = "gitops-hashicups"
  vpc_id             = var.vpc_id
  public_subnet_ids  = var.public_subnet_ids
  private_subnet_ids = var.private_subnet_ids

  managed_node_groups = {
    mg_m5 = {
      node_group_name = "managed-ondemand"
      desired_size    = "2"
      max_size        = "3"
      min_size        = "2"
      instance_types  = ["m5.large"]
      subnet_ids      = var.private_subnet_ids
    }
  }
}

resource "time_sleep" "wait" {
  depends_on      = [module.eks_cluster]
  create_duration = "3m"
}

module "eks_addons" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons?ref=v4.10.0"

  # EKS Addons
  enable_amazon_eks_vpc_cni            = true
  enable_amazon_eks_coredns            = true
  enable_amazon_eks_kube_proxy         = true
  enable_amazon_eks_aws_ebs_csi_driver = true

  #K8s Add-ons
  eks_cluster_id                      = module.eks_cluster.eks_cluster_id
  enable_aws_load_balancer_controller = true
  enable_external_dns                 = true
  enable_metrics_server               = true
  enable_prometheus                   = true

  eks_cluster_domain = var.eks_cluster_domain
  external_dns_helm_config = {
    set_values = [
      {
        name  = "domainFilters"
        value = var.route53_domains
      }
    ]
  }

  depends_on = [time_sleep.wait]
}
