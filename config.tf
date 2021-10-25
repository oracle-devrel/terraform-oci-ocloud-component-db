# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

// Global settings and naming conventions
// In order to apply these settings run the following command 'terraform plan -var tenancy_ocid=$OCI_TENANCY -var compartment_ocid="..." -out config.tfplan'
// and than 'terraform apply "config.tfplan" -auto-approve'

## --- OCI service provider ---
provider "oci" {
  alias                = "home"
  region               = local.regions_map[local.home_region_key]
}

# Basic DB Configuration temaplates
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
#data "oci_identity_availability_domains" "ads"     { compartment_id = var.tenancy_ocid }      # Get a list of Availability Domains
#data "oci_identity_compartments"         "root"    { compartment_id = var.tenancy_ocid }      # List root compartments
# data "oci_objectstorage_namespace"       "ns"      { compartment_id = var.tenancy_ocid }      # Retrieve object storage namespace
# data "template_file" "ad_names"                    {                                          # List AD names in home region 
#   count    = length(data.oci_identity_availability_domains.ads.availability_domains)
#   template = lookup(data.oci_identity_availability_domains.ads.availability_domains[count.index], "name")
# }

## --- input functions ---
# Define the home region identifier
locals {
  # Discovering the home region name and region key.
  regions_map         = {for rgn in data.oci_identity_regions.global.regions : rgn.key => rgn.name} # All regions indexed by region key.
  # regions_map_reverse = {for rgn in data.oci_identity_regions.global.regions : rgn.name => rgn.key} # All regions indexed by region name.
  home_region_key     = data.oci_identity_tenancy.ocloud.home_region_key                            # Home region key obtained from the tenancy data source
  # home_region         = local.regions_map[local.home_region_key]                                # Region key obtained from the region name

  # Service label
  # service_label = format("%s%s", lower(substr(var.organization, 0, 3)), lower(substr(var.project, 0, 5)))
  # service_name  = lower("${var.organization}_${var.project}")
}

## --- global outputs ----
# output "config_account"   { value = data.oci_identity_tenancy.ocloud }
# output "config_namespace" { value = data.oci_objectstorage_namespace.ns.namespace }
# output "config_ad_names"  { value = sort(data.template_file.ad_names.*.rendered) } # List of ADs in the selected region