# terraform-oci-object-storage

Terraform module that creates an OCI Object Storage bucket with optional retention, lifecycle and cross-region replication rules, and pre-authenticated requests.

## Usage

```hcl
module "bucket" {
  source  = "blissflow-tech/object-storage/oci"
  version = "~> 1.0"

  providers = {
    oci      = oci
    oci.home = oci.home
  }

  region    = "us-ashburn-1"
  namespace = var.namespace

  bucket = {
    compartment_id = var.compartment_id
    name           = "app-data"
    versioning     = "Enabled"

    retention_rules = [
      { display_name = "keep-30-days", time_amount = 30, time_unit = "DAYS" },
    ]

    lifecycle_rules = [
      {
        name        = "archive-logs"
        action      = "ARCHIVE"
        is_enabled  = true
        target      = "objects"
        time_amount = 90
        time_unit   = "DAYS"
        object_name_filters = {
          inclusion_prefixes = ["logs/"]
        }
      },
    ]

    replication_rules = {
      policy_name        = "app-data-replication"
      destination_region = "us-phoenix-1"
      destination_bucket = "app-data-replica"
    }
  }

  objectstorage_service_policy_name = "app-data-objectstorage-service"
}
```

## Notes

* The module needs two OCI providers: `oci` for the bucket region and `oci.home`, aliased to the tenancy home region, for the IAM policy. Pass both even when you don't replicate.
* Replication creates an IAM policy that lets the regional Object Storage service manage objects in the bucket's compartment, so `objectstorage_service_policy_name` is required whenever `replication_rules` is set.
* `retention_rules[*].time_unit` must be uppercase `DAYS` or `YEARS`.
* Pre-authenticated requests are named after their map key, and the `access_uri` in the output is a bearer URL that grants access by itself, so it is marked sensitive. A root output that exposes `bucket` needs `sensitive = true` once the bucket has pre-authenticated requests.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| terraform | >= 1.3 |
| oci | >= 8.0, < 10.0 |

## Providers

| Name | Version |
| ---- | ------- |
| oci | >= 8.0, < 10.0 |
| oci.home | >= 8.0, < 10.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [oci_identity_policy.objectstorage_service](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_policy) | resource |
| [oci_objectstorage_bucket.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/objectstorage_bucket) | resource |
| [oci_objectstorage_object_lifecycle_policy.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/objectstorage_object_lifecycle_policy) | resource |
| [oci_objectstorage_preauthrequest.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/objectstorage_preauthrequest) | resource |
| [oci_objectstorage_replication_policy.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/objectstorage_replication_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| bucket | Bucket to create, with optional retention, lifecycle, replication and pre-authenticated request settings | <pre>object({<br/>    provider              = optional(string)<br/>    compartment_id        = string<br/>    name                  = optional(string)<br/>    access_type           = optional(string, "NoPublicAccess")<br/>    auto_tiering          = optional(string)<br/>    freeform_tags         = optional(map(string))<br/>    defined_tags          = optional(map(string))<br/>    versioning            = optional(string)<br/>    object_events_enabled = optional(bool)<br/>    storage_tier          = optional(string, "Standard")<br/>    retention_rules = optional(list(object({<br/>      display_name = string<br/>      time_amount  = number<br/>      time_unit    = string<br/>    })), [])<br/>    replication_rules = optional(object({<br/>      policy_name        = string<br/>      destination_region = string<br/>      destination_bucket = string<br/>    }))<br/>    lifecycle_rules = optional(list(object({<br/>      name        = string<br/>      action      = string<br/>      is_enabled  = bool<br/>      target      = string<br/>      time_amount = number<br/>      time_unit   = string<br/>      object_name_filters = optional(object({<br/>        exclusion_patterns = optional(list(string))<br/>        inclusion_patterns = optional(list(string))<br/>        inclusion_prefixes = optional(list(string))<br/>      }))<br/>    })))<br/>    preauthenticated_request = optional(map(object({<br/>      access_type           = string<br/>      name                  = string<br/>      time_expires          = string<br/>      bucket_listing_action = optional(string)<br/>      object_name           = optional(string)<br/>    })), {})<br/>  })</pre> | n/a | yes |
| namespace | Object storage namespace | `string` | n/a | yes |
| region | Region identifier of the bucket, e.g. us-ashburn-1. Used to name the Object Storage service principal in the replication policy. | `string` | n/a | yes |
| objectstorage\_service\_policy\_name | Name of the IAM policy that lets the Object Storage service replicate the bucket. Required when bucket.replication\_rules is set. | `string` | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| bucket | Bucket attributes, plus the replication service policy and any pre-authenticated requests |
<!-- END_TF_DOCS -->

## License

Apache 2.0. See [LICENSE](LICENSE).
