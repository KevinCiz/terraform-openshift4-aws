locals {
  tags = merge(
    {
      "kubernetes.io/cluster/${module.installer.infraID}" = "owned"
    },
    var.aws_extra_tags,
  )
  aws_azs = (var.aws_azs != null) ? var.aws_azs : tolist([join("", [var.aws_region, "a"]), join("", [var.aws_region, "b"])])
}

provider "aws" {
  region = var.aws_region

  skip_region_validation = var.aws_skip_region_validation

  # endpoints {
  #   ec2     = lookup(var.custom_endpoints, "ec2", null)
  #   elb     = lookup(var.custom_endpoints, "elasticloadbalancing", null)
  #   iam     = lookup(var.custom_endpoints, "iam", null)
  #   route53 = lookup(var.custom_endpoints, "route53", null)
  #   s3      = lookup(var.custom_endpoints, "s3", null)
  #   sts     = lookup(var.custom_endpoints, "sts", null)
  # }
}

module "bootstrap" {
  source = "./bootstrap"

  ami                      = var.rhcos_image
  instance_type            = var.aws_bootstrap_instance_type
  cluster_id               = module.installer.infraID
  ignition                 = module.installer.bootstrap_ign
  subnet_id                = var.aws_private_subnets[0]
  target_group_arns        = module.vpc.aws_lb_target_group_arns
  target_group_arns_length = module.vpc.aws_lb_target_group_arns_length
  vpc_id                   = var.vpc_id
  vpc_cidrs                = [var.vpc_cidr_range]
  vpc_security_group_ids   = [module.vpc.master_sg_id]
  volume_kms_key_id        = var.aws_master_root_volume_kms_key_id
  publish_strategy         = var.aws_publish_strategy
  restricted               = var.restricted
  permission_boundary_arn  = var.permission_boundary_arn

  tags = merge(local.tags, var.restricted ? var.restricted_ec2_tags : {})
}

module "masters" {
  source = "./master"

  cluster_id    = module.installer.infraID
  instance_type = var.aws_master_instance_type

  tags = merge(local.tags, var.restricted ? var.restricted_ec2_tags : {})

  availability_zones       = local.aws_azs
  subnet_id                = var.aws_private_subnets[0]
  instance_count           = 3
  master_sg_ids            = [module.vpc.master_sg_id]
  root_volume_iops         = var.aws_master_root_volume_iops
  root_volume_size         = var.aws_master_root_volume_size
  root_volume_type         = var.aws_master_root_volume_type
  root_volume_encrypted    = var.aws_master_root_volume_encrypted
  root_volume_kms_key_id   = var.aws_master_root_volume_kms_key_id
  target_group_arns        = module.vpc.aws_lb_target_group_arns
  target_group_arns_length = module.vpc.aws_lb_target_group_arns_length
  ec2_ami                  = var.rhcos_image
  user_data_ign            = module.installer.master_ign
  publish_strategy         = var.aws_publish_strategy
  restricted               = var.restricted
  permission_boundary_arn  = var.permission_boundary_arn
}

module "iam" {
  source = "./iam"

  cluster_id = module.installer.infraID
  restricted               = var.restricted
  permission_boundary_arn  = var.permission_boundary_arn

  tags = local.tags
}


module "dns" {
  count = var.openshift_byo_dns ? 0 : 1

  source = "./route53"

  api_external_lb_dns_name = module.vpc.aws_lb_api_external_dns_name
  api_external_lb_zone_id  = module.vpc.aws_lb_api_external_zone_id
  api_internal_lb_dns_name = module.vpc.aws_lb_api_internal_dns_name
  api_internal_lb_zone_id  = module.vpc.aws_lb_api_internal_zone_id
  base_domain              = var.base_domain
  cluster_domain           = "${var.cluster_name}.${var.base_domain}"
  cluster_id               = module.installer.infraID
  tags                     = local.tags
  vpc_id                   = var.vpc_id
  region                   = var.aws_region
  publish_strategy         = var.aws_publish_strategy
}

module "vpc" {
  source = "./vpc"

  cidr_blocks        = [var.vpc_cidr_range]
  cluster_id         = module.installer.infraID
  region             = var.aws_region
  vpc                = var.vpc_id
  public_subnets     = []
  private_subnets    = var.aws_private_subnets
  publish_strategy   = var.aws_publish_strategy
  airgapped          = var.airgapped
  availability_zones = local.aws_azs

  tags = local.tags
}

module "installer" {
  source = "./install"

  ami                               = var.rhcos_image
  private_route53_hostedZone        = var.private_hosted_zone
  clustername                       = var.cluster_name
  domain                            = var.base_domain
  vpc_cidr_block                    = var.vpc_cidr_range
  infra_count                       = var.infra_count
  publish_strategy                  = var.aws_publish_strategy
  openshift_pull_secret             = var.openshift_pull_secret
  aws_worker_availability_zones     = local.aws_azs
  aws_worker_instance_type          = var.aws_worker_instance_type
  aws_infra_instance_type           = var.aws_infra_instance_type
  aws_private_subnets               = var.aws_private_subnets
  airgapped                         = var.airgapped
  proxy_config                      = var.proxy_config
  public_ssh_key                    = var.public_ssh_key
  openshift_additional_trust_bundle = var.openshift_additional_trust_bundle
  byo_dns                           = var.openshift_byo_dns
  ec2_vpce_endpoint                 = var.ec2_vpce_endpoint
}
