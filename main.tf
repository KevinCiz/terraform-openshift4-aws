locals {
  tags = merge(
    {
      "kubernetes.io/cluster/${module.installer.infraID}" = "owned"
    },
    var.aws_extra_tags,
  )
  aws_azs         = (var.aws_azs != null) ? var.aws_azs : tolist([join("",[var.aws_region,"a"]),join("",[var.aws_region,"b"])])
  rhcos_image = "ami-06871a4749ba8de33"
}

provider "aws" {
  region = var.aws_region

  skip_region_validation = var.aws_skip_region_validation
}

module "bootstrap" {
  source = "./bootstrap"

  ami                      = local.rhcos_image
  instance_type            = var.aws_bootstrap_instance_type
  cluster_id               = module.installer.infraID
  ignition                 = module.installer.bootstrap_ign
  subnet_id                = "subnet-08e10c6969d08ee2a"
  target_group_arns        = module.vpc.aws_lb_target_group_arns
  target_group_arns_length = module.vpc.aws_lb_target_group_arns_length
  vpc_id                   = "vpc-0c60661a26d31a3c4"
  vpc_cidrs                = ["10.1.0.0/16"]
  vpc_security_group_ids   = [module.vpc.master_sg_id]
  volume_kms_key_id        = var.aws_master_root_volume_kms_key_id
  publish_strategy         = var.aws_publish_strategy

  tags = local.tags
}

# module "masters" {
#   source = "./master"

#   cluster_id    = module.installer.infraID
#   instance_type = var.aws_master_instance_type

#   tags = local.tags

#   availability_zones       = local.aws_azs
#   az_to_subnet_id          = module.vpc.az_to_private_subnet_id
#   instance_count           = length(local.aws_azs)
#   master_sg_ids            = [module.vpc.master_sg_id]
#   root_volume_iops         = var.aws_master_root_volume_iops
#   root_volume_size         = var.aws_master_root_volume_size
#   root_volume_type         = var.aws_master_root_volume_type
#   root_volume_encrypted    = var.aws_master_root_volume_encrypted
#   root_volume_kms_key_id   = var.aws_master_root_volume_kms_key_id
#   target_group_arns        = module.vpc.aws_lb_target_group_arns
#   target_group_arns_length = module.vpc.aws_lb_target_group_arns_length
#   ec2_ami                  = local.rhcos_image
#   user_data_ign            = module.installer.master_ign
#   publish_strategy         = var.aws_publish_strategy
# }

# module "iam" {
#   source = "./iam"

#   cluster_id = module.installer.infraID

#   tags = local.tags
# }


# module "dns" {
#   count                    = var.openshift_byo_dns ? 0 : 1

#   source = "./route53"

#   api_external_lb_dns_name = module.vpc.aws_lb_api_external_dns_name
#   api_external_lb_zone_id  = module.vpc.aws_lb_api_external_zone_id
#   api_internal_lb_dns_name = module.vpc.aws_lb_api_internal_dns_name
#   api_internal_lb_zone_id  = module.vpc.aws_lb_api_internal_zone_id
#   base_domain              = var.base_domain
#   cluster_domain           = "${var.cluster_name}.${var.base_domain}"
#   cluster_id               = module.installer.infraID
#   tags                     = local.tags
#   vpc_id                   = module.vpc.vpc_id
#   region                   = var.aws_region
#   publish_strategy         = var.aws_publish_strategy
# }

module "installer" {
  source = "./install"

  ami = local.rhcos_image
  private_route53_hostedZone = "Z10363623QINZFL0RQYO7"
  clustername = var.cluster_name
  domain = var.base_domain
  vpc_cidr_block = "10.1.0.0/16"
  infra_count = var.infra_count
  publish_method = "External"
  openshift_pull_secret = var.openshift_pull_secret
  aws_worker_availability_zones = local.aws_azs
  aws_worker_instance_type = var.aws_worker_instance_type
  aws_infra_instance_type = var.aws_infra_instance_type
  aws_private_subnets = ["subnet-01402bf17b063d40e","subnet-08e10c6969d08ee2a"]
  airgapped = var.airgapped
  proxy_config = var.proxy_config
  public_ssh_key =  var.public_ssh_key
  openshift_additional_trust_bundle = var.openshift_additional_trust_bundle
  byo_dns = var.openshift_byo_dns
}
