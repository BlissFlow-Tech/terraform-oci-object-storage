resource "oci_objectstorage_bucket" "this" {
  provider              = oci
  compartment_id        = var.bucket.compartment_id
  namespace             = local.namespace
  name                  = var.bucket.name
  access_type           = var.bucket.access_type
  auto_tiering          = var.bucket.auto_tiering
  freeform_tags         = var.bucket.freeform_tags
  defined_tags          = var.bucket.defined_tags
  versioning            = var.bucket.versioning
  object_events_enabled = var.bucket.object_events_enabled
  storage_tier          = var.bucket.storage_tier

  dynamic "retention_rules" {
    for_each = var.bucket.retention_rules
    content {
      display_name = retention_rules.value.display_name
      duration {
        time_amount = retention_rules.value.time_amount
        time_unit   = retention_rules.value.time_unit
      }
    }
  }
  lifecycle {
    ignore_changes = [
      defined_tags["Oracle-Tags.CreatedBy"],
      defined_tags["Oracle-Tags.CreatedOn"],
    ]
  }
}

resource "oci_objectstorage_replication_policy" "this" {
  count                   = var.bucket.replication_rules != null ? 1 : 0
  provider                = oci
  depends_on              = [oci_identity_policy.objectstorage_service]
  name                    = var.bucket.replication_rules.policy_name
  bucket                  = oci_objectstorage_bucket.this.name
  namespace               = local.namespace
  destination_bucket_name = var.bucket.replication_rules.destination_bucket
  destination_region_name = var.bucket.replication_rules.destination_region
}

resource "oci_objectstorage_object_lifecycle_policy" "this" {
  count     = var.bucket.lifecycle_rules != null ? 1 : 0
  provider  = oci
  bucket    = oci_objectstorage_bucket.this.name
  namespace = local.namespace

  dynamic "rules" {
    for_each = var.bucket.lifecycle_rules
    content {
      name       = rules.value.name
      action     = rules.value.action
      is_enabled = rules.value.is_enabled
      target     = rules.value.target

      time_amount = rules.value.time_amount
      time_unit   = rules.value.time_unit

      dynamic "object_name_filter" {
        for_each = rules.value.object_name_filters != null ? [rules.value.object_name_filters] : []
        content {
          exclusion_patterns = object_name_filter.value.exclusion_patterns
          inclusion_patterns = object_name_filter.value.inclusion_patterns
          inclusion_prefixes = object_name_filter.value.inclusion_prefixes
        }
      }
    }
  }
}


resource "oci_identity_policy" "objectstorage_service" {
  count          = var.bucket.replication_rules != null ? 1 : 0
  provider       = oci.home
  description    = "IAM policy for bucket ${var.bucket.name}"
  compartment_id = var.bucket.compartment_id
  name           = var.objectstorage_service_policy_name
  statements = [
    "Allow service ${local.objectstorage_service} to manage object-family in compartment id ${var.bucket.compartment_id}"
  ]
}

resource "oci_objectstorage_preauthrequest" "this" {
  for_each = {
    for idx, v in var.bucket.preauthenticated_request : idx => v
  }
  provider              = oci
  access_type           = each.value.access_type
  bucket                = oci_objectstorage_bucket.this.name
  name                  = each.key
  namespace             = local.namespace
  time_expires          = each.value.time_expires
  bucket_listing_action = each.value.bucket_listing_action
  object_name           = each.value.object_name
}
