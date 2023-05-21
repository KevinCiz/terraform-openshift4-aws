variable "clustername" {
  type        = string
  description = "The identifier for the cluster."
}

variable "domain" {
  type        = string
  description = "The DNS domain for the cluster."
}

variable "ami" {
  type        = string
  description = "The AMI ID for the RHCOS nodes"
}

variable "cluster_network_cidr" {
  type        = string
  default     = "192.168.0.0/17"
}

variable "service_network_cidr" {
  type        = string
  default     = "192.168.128.0/24"
}

variable "vpc_cidr_block" {
  type        = string
  default     = "10.1.0.0/16"
}

variable "cluster_network_host_prefix" {
  type        = string
  default     = "23"
}

variable "aws_worker_instance_type" {
  type = string
  description = "Instance type for the worker node(s). Example: `m4.large`."
}

variable "aws_worker_root_volume_type" {
  type        = string
  description = "The type of volume for the root block device of worker nodes."
  default = "gp3"
}

variable "aws_worker_root_volume_size" {
  type        = string
  description = "The size of the volume in gigabytes for the root block device of worker nodes."
  default = 120
}

variable "aws_worker_root_volume_iops" {
  type = string

  description = <<EOF
The amount of provisioned IOPS for the root block device of worker nodes.
Ignored if the volume type is not io1.
EOF

  default = "0"
}

variable "infra_count" {
  type        = number
  description = "The number of infra nodes."
  default     = 0
}

variable "aws_infra_instance_type" {
  type = string
  description = "Instance type for the infra node(s). Example: `m4.large`."
  default = "m6i.xlarge"
}

variable "aws_infra_root_volume_type" {
  type        = string
  description = "The type of volume for the root block device of infra nodes."
  default = "gp3"
}

variable "aws_infra_root_volume_size" {
  type        = string
  description = "The size of the volume in gigabytes for the root block device of infra nodes."
  default = 120
}

variable "aws_infra_root_volume_iops" {
  type = string

  description = <<EOF
The amount of provisioned IOPS for the root block device of infra nodes.
Ignored if the volume type is not io1.
EOF
  default = 0

}

variable "public_ssh_key" {
  type = string
  description = "SSH.pub key that require to ssh into the nodes."
}


variable "openshift_pull_secret" {
  type        = string
  description = "Value will be getting from environments tf.vars"
}

# variable "aws_access_key_id" {
#   type        = string
#   description = "AWS access key"
# }

# variable "aws_secret_access_key" {
#   type        = string
#   description = "AWS Secret"
# }

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "ap-southeast-1"
}

variable "aws_worker_availability_zones" {
  type = list(string)
  description = "The availability zones to provision for workers.  Worker instances are created by the machine-API operator, but this variable controls their supporting infrastructure (subnets, routing, etc.)."
}

variable "aws_private_subnets" {
  type = list(string)
  description = "The private subnets for workers. This is used when the subnets are preconfigured."
}

variable "publish_method" {
  type = string
  description = "The publish strategy for openshift. Accepted Value (Internal | External)"
}

variable "airgapped" {
  type = map(string)
  default = {
    enabled  = false
    repository = ""
  }
}

variable "openshift_additional_trust_bundle" {
  type = string
}

variable "byo_dns" {
  type = bool
}

variable "proxy_config" {
  type = map(string)
  default = {
    enabled = false
  }
}

variable "private_route53_hostedZone" {
  type = string
  description = "Private Route53 HostedZone id"
}