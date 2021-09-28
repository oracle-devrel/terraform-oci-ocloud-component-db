# Copyright (c) 2019, 2021, Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# general oci parameters

variable "tenancy_ocid" {}

variable "user_ocid" {
  default = ""
}

variable "fingerprint" {
  default = ""
}

variable "private_key_path" {
  default = ""
}

variable "region" {}

variable "compartment_ocid" {
  description = "compartment ocid where to create the database"
  type        = string
  # no default value, asking user to explicitly set this variable's value. see codingconventions.adoc
}

# adb parameters

variable "owner" {
  description = "Used for database name and display name, <label><prefix><database name>"
  type        = string
  # no default value, asking user to explicitly set this variable's value. see codingconventions.adoc  
}

variable "project" {
  description = "Used for database name and display name, <label><prefix><database name>"
  type        = string
  # no default value, asking user to explicitly set this variable's value. see codingconventions.adoc  
}

variable "cpu_core_count" {
  description = "The number of OCPU cores to be made available to the database. "
  type        = number
  default = 1
}

variable "data_storage_tbs" {
  description = "The size, in terabytes, of the data volume that will be created and attached to the database. This storage can later be scaled up if needed"
  type        = number
  default = 1
}

variable "autoscaling_enabled" {
  description =  "Indicates if auto scaling is enabled for the Autonomous Database CPU core count"
  type        = bool
  default = false
}

variable "workload_type" {
  description =  "Select Workload Type"
  type        = string
  default = "OLTP"
}

# Optional Object storage bucket for manual backups

variable "object_storage" {
  description =  "Create a Object Storage Bucket for manual backups"
  type        = bool
  default = false
}

# Network parameter for database private endpoints. These resources need to be created as
# part of CIS Landing Zone.

variable "nw_compartment_ocid" {
  description = "Network compartment ocid where network resources can be found."
  type        = string
  default = ""
}

variable "vcn_id" {
  description =  "OCID of VCN where the ADB's private endpoint will be placed"
  type        = string
  default = ""
}

variable "subnet_id" {
  description =  "Subnet OCID where the ADB's private endpoint will be placed"
  type        = string
  default = ""
}

variable "nsg_id" {
  description =  "NSG to access database"
  type        = string
  default = ""
}
