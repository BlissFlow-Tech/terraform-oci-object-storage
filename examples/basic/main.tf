provider "oci" {
  region = var.region
}

provider "oci" {
  alias  = "home"
  region = var.home_region
}

module "bucket" {
  source = "../.."

  providers = {
    oci      = oci
    oci.home = oci.home
  }

  region    = var.region
  namespace = var.namespace

  bucket = {
    compartment_id = var.compartment_id
    name           = "example-bucket"
    versioning     = "Enabled"
  }
}

output "bucket_id" {
  value = module.bucket.bucket.bucket_id
}
