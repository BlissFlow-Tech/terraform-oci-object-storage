output "bucket" {
  description = "Bucket attributes, plus the replication service policy and any pre-authenticated requests"

  value = {
    id                    = one(oci_objectstorage_bucket.this[*].id)
    bucket_id             = one(oci_objectstorage_bucket.this[*].bucket_id)
    name                  = one(oci_objectstorage_bucket.this[*].name)
    namespace             = one(oci_objectstorage_bucket.this[*].namespace)
    compartment_id        = one(oci_objectstorage_bucket.this[*].compartment_id)
    metadata              = one(oci_objectstorage_bucket.this[*].metadata)
    access_type           = one(oci_objectstorage_bucket.this[*].access_type)
    storage_tier          = one(oci_objectstorage_bucket.this[*].storage_tier)
    versioning            = one(oci_objectstorage_bucket.this[*].versioning)
    auto_tiering          = one(oci_objectstorage_bucket.this[*].auto_tiering)
    object_events_enabled = one(oci_objectstorage_bucket.this[*].object_events_enabled)
    replication_enabled   = one(oci_objectstorage_bucket.this[*].replication_enabled)
    kms_key_id            = one(oci_objectstorage_bucket.this[*].kms_key_id)
    defined_tags          = one(oci_objectstorage_bucket.this[*].defined_tags)
    freeform_tags         = one(oci_objectstorage_bucket.this[*].freeform_tags)
    retention_rules       = one(oci_objectstorage_bucket.this[*].retention_rules)
    time_created          = one(oci_objectstorage_bucket.this[*].time_created)
    service_policy = {
      id             = one(oci_identity_policy.objectstorage_service[*].id)
      name           = one(oci_identity_policy.objectstorage_service[*].name)
      compartment_id = one(oci_identity_policy.objectstorage_service[*].compartment_id)
      statements     = one(oci_identity_policy.objectstorage_service[*].statements)
    }
    preauthenticated_requests = length(oci_objectstorage_preauthrequest.this) > 0 ? {
      for k, v in oci_objectstorage_preauthrequest.this :
      k => {
        id                    = v.id
        name                  = v.name
        access_uri            = v.access_uri
        time_expires          = v.time_expires
        access_type           = v.access_type
        bucket                = v.bucket
        object_name           = v.object_name
        bucket_listing_action = v.bucket_listing_action
      }
    } : null
  }
}
