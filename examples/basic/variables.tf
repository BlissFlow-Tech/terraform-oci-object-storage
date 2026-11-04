variable "region" {
  description = "Region of the bucket"
  type        = string
}

variable "home_region" {
  description = "Home region of the tenancy, used for IAM"
  type        = string
}

variable "namespace" {
  description = "Object Storage namespace of the tenancy"
  type        = string
}

variable "compartment_id" {
  description = "OCID of the compartment that holds the bucket"
  type        = string
}
