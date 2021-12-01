# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

## --- OCI service provider ---
provider "oci" {
  alias                = "home"
  region               = local.regions_map[local.home_region_key]
}

# Basic DB Configuration templates
variable "db_basic_config" {
  type = map(object({
    system_shape = string
    storage_size_in_gb = string
  }))

  default = {
    small = {
      system_shape = "VM.Standard2.2"
      storage_size_in_gb    = 512
    },
    medium = {
      system_shape = "VM.Standard2.8"
      storage_size_in_gb    = 4096
    },
    large = {
      system_shape = "VM.Standard2.16"
      storage_size_in_gb    = 8192
    }
  }
}

## --- settings ---
# variable "base_url" {
#   type        = string
#   description = "URL for the git repository which gets added to "
#   default     = "https://github.com/oracle-devrel/terraform-oci-ocloud-db"
# }

## --- data sources ---
data "oci_identity_regions"              "global"  { }                                        # Retrieve a list OCI regions
data "oci_identity_tenancy"              "ocloud"  { tenancy_id     = var.tenancy_ocid }      # Retrieve meta data for tenant


## --- input functions ---
# Define the home region identifier
locals {
  # Discovering the home region name and region key.
  regions_map         = {for rgn in data.oci_identity_regions.global.regions : rgn.key => rgn.name} # All regions indexed by region key.
  home_region_key     = data.oci_identity_tenancy.ocloud.home_region_key                            # Home region key obtained from the tenancy data source
}