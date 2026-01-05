###################
# Perimeter / Common Variables
###################

variable "account_id" {
  description = "AWS account ID for the perimeter account (used for tagging/metadata if needed)."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the NLB and endpoint service will be created."
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for the NLB nodes."
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to AWS resources."
  type        = map(string)
  default     = {}
}

###################
# PrivateLink Services (per-service config)
###################

variable "pl_services" {
  description = "Map of PrivateLink services to create."
  type = map(object({
    name = string

    service_target_ips = list(string)
    listener_port      = optional(number, 443)
    protocol           = optional(string, "TCP")

    acceptance_required = optional(bool, true)
    allowed_principals  = optional(set(string), [])
  }))

  validation {
    condition     = alltrue([for _, svc in var.pl_services : length(svc.service_target_ips) == 3])
    error_message = "Each pl_service must provide exactly 3 service_target_ips."
  }
}

