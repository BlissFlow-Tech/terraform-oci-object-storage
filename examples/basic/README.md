# Basic example

Creates a private, versioned bucket. It configures the regional and home-region OCI providers the module expects.

```sh
terraform init
terraform apply \
  -var region=us-ashburn-1 \
  -var home_region=us-ashburn-1 \
  -var namespace=<namespace> \
  -var compartment_id=<compartment-ocid>
```
