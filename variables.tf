variable "region" {
  type        = string
  description = "Region identifier of the bucket, e.g. us-ashburn-1. Used to name the Object Storage service principal in the replication policy."
}

variable "namespace" {
  description = "Object storage namespace"
  type        = string
}

variable "bucket" {
  description = "Bucket to create, with optional retention, lifecycle, replication and pre-authenticated request settings"
  type = object({
    compartment_id        = string
    name                  = optional(string)
    access_type           = optional(string, "NoPublicAccess")
    auto_tiering          = optional(string)
    freeform_tags         = optional(map(string))
    defined_tags          = optional(map(string))
    versioning            = optional(string)
    object_events_enabled = optional(bool)
    storage_tier          = optional(string, "Standard")
    retention_rules = optional(list(object({
      display_name = string
      time_amount  = number
      time_unit    = string
    })), [])
    replication_rules = optional(object({
      policy_name        = string
      destination_region = string
      destination_bucket = string
    }))
    lifecycle_rules = optional(list(object({
      name        = string
      action      = string
      is_enabled  = bool
      target      = string
      time_amount = number
      time_unit   = string
      object_name_filters = optional(object({
        exclusion_patterns = optional(list(string))
        inclusion_patterns = optional(list(string))
        inclusion_prefixes = optional(list(string))
      }))
    })))
    preauthenticated_request = optional(map(object({
      access_type           = string
      name                  = string
      time_expires          = string
      bucket_listing_action = optional(string)
      object_name           = optional(string)
    })), {})
  })
  validation {
    condition = alltrue([
      for r in coalesce(var.bucket.retention_rules, []) :
      contains(["DAYS", "YEARS"], r.time_unit)
    ])
    error_message = "retention_rules.time_unit must be DAYS or YEARS (uppercase). OCI Object Storage is case-sensitive."
  }
}

variable "objectstorage_service_policy_name" {
  description = "Name of the IAM policy that lets the Object Storage service replicate the bucket. Required when bucket.replication_rules is set."
  type        = string
  default     = null
}
