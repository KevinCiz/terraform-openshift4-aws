variable "cluster_id" {
  type = string
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "AWS tags to be applied to created resources."
}

variable "restricted" {
  type = bool
  description = "Set to true if we want to specify Permission boundary and Add Ec2 Tagging"
}

variable "permission_boundary_arn" {
  type = string
  description = "iam permission boundary arn"
}
