variable "environment" {
  description = "The environment in which the service is being deployed."
  type        = string
  default     = "development"
}

variable "instance_type" {
  description = "The instance type to use for the bastion host."
  type        = string
  default     = "t2.micro"
}

variable "key_pair_name" {
  description = "The name of the key pair to use for the bastion host. Defaults to: project-environment-bastion"
  type        = string
  default     = ""
}

variable "kms_key_recovery_period" {
  type        = number
  default     = 30
  description = "Recovery period for deleted KMS keys in days. Must be between 7 and 30."

  validation {
    condition     = var.kms_key_recovery_period > 6 && var.kms_key_recovery_period < 31
    error_message = "Recovery period must be between 7 and 30."
  }
}

variable "private_subnet_ids" {
  description = "The IDs of the private subnets in which the bastion host should be deployed."
  type        = list(string)
}

variable "project" {
  type        = string
  description = "Project that these resources are supporting."
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources."
  default     = {}
}

variable "vpc_id" {
  description = "The ID of the VPC in which the bastion host should be deployed."
  type        = string
}
