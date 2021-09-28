# network part for ADB private endpoint, added by Ingo and Rares, 15-Jul-2021

/* # NSG for ADB private endpoint
resource "oci_core_network_security_group" "adb_nsg" {
    display_name   = "Network Security Group for Autonomous Database Private Endpoint"
    compartment_id = var.compartment_ocid
    vcn_id = var.vcn_id
}

# Rules for NSG for ADB private endpoint

# egress rule, tcp egress to anywhere
resource "oci_core_network_security_group_security_rule" "adb_nsg_egress_security_rule" {
    network_security_group_id = oci_core_network_security_group.adb_nsg.id
    direction = "EGRESS" 
    protocol = "6" 

    description = "allow everything for egress" 
    destination = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    stateless = "false"
}

# ingress rule, port 1522 / tcp from anywhere
resource "oci_core_network_security_group_security_rule" "adb_nsg_ingress_security_rule" {
    network_security_group_id = oci_core_network_security_group.adb_nsg.id
    direction = "INGRESS"
    protocol = "6"
    
    description = "allow port 1522 only for ingress"
    source = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless = "false"
    tcp_options {
        destination_port_range {
            max = "1522" 
            min = "1522" 
        }
    }   
}

## --- subnet ---
resource "oci_core_subnet" "adb_subnet" {
  cidr_block                 = cidrsubnet(var.cidr_block, var.newbits, var.netnum)
  dns_label                  = "adbsubnet"
  display_name               = "Subnet for Autonomous Database Private Endpoint"
  compartment_id             = var.compartment_ocid
  vcn_id                     = var.vcn_id 
  security_list_ids          = [oci_core_security_list.adb_subnet_security_list.id]
}

## --- security list ---
resource "oci_core_security_list" "adb_subnet_security_list" {
    #Required
    compartment_id = var.compartment_ocid
    vcn_id = var.vcn_id 

    display_name = "Security list that allows ingress to port 1522 only and egress to anywhere"

  egress_security_rules  {
    protocol    = "6"
    destination = "0.0.0.0/0"
  }
  egress_security_rules    {
      protocol    = "1"
      destination = "0.0.0.0/0"
    }
  egress_security_rules    {
      protocol    = "17"
      destination = "0.0.0.0/0"
    }


ingress_security_rules  {
    tcp_options {
      max = 1522
      min = 1522
    }

    protocol = "6"
    source   = "0.0.0.0/0"
  }
} */

# end of network part, added by Ingo and Rares, 15-Jul-2021


// ---- Generate a password
resource "random_string" "password" {
  # must contains at least 2 upper case letters, 2 lower case letters, 2 numbers and 2 special characters
  length      = 16
  upper       = true
  min_upper   = 2
  lower       = true
  min_lower   = 2
  number      = true
  min_numeric = 2
  special     = true
  min_special = 2
  override_special = "#+-="   # use only special characters in this list
}

# ---- OCI bucket for manual backups
# -- see https://docs.cloud.oracle.com/iaas/Content/Database/Tasks/adbbackingup.htm

data "oci_objectstorage_namespace" "ns" {
    #Optional
    compartment_id = var.compartment_ocid
}

resource "oci_objectstorage_bucket" "backup" {
  count = var.object_storage ? 1 : 0
  compartment_id = var.compartment_ocid
  name           = "backup_${local.adbs_name}"         # this name must not be changed (expected name)
  namespace      = data.oci_objectstorage_namespace.ns.namespace
}

# ---- Serverless autonomous database: ATP or ADW
resource "oci_database_autonomous_database" "adb" {
  db_workload              = var.workload_type
  admin_password           = random_string.password.result
  compartment_id           = local.db_compartment_ocid
  cpu_core_count           = var.cpu_core_count          # not used for free instance
  data_storage_size_in_tbs = var.data_storage_tbs        # not used for free instance
  db_name                  = local.adbs_name

  display_name             = local.adbs_display_name
  license_model            = "BRING_YOUR_OWN_LICENSE"
  is_auto_scaling_enabled  = var.autoscaling_enabled
  is_free_tier             = false
  # attributes added by Ingo and Rares for private endpoint, 15-Jul-2021
  nsg_ids                  = [local.db_nsg_ocid]
  private_endpoint_label   = "${local.adbs_name}PrivateEndpoint"
  subnet_id                = local.db_subnet_ocid
}

resource "random_string" "wallet_password" {
  length  = 16
  special = true
}

output "adw_password" { value = random_string.password.result }
output "adw_wallet_password" { value = random_string.wallet_password.result }
output "all_connection_strings" { value = oci_database_autonomous_database.adb.connection_strings.0.all_connection_strings }

#output "autonomous_database_high_connection_string" {
#  value = "${lookup(oci_database_autonomous_database.autonomous_database.connection_strings.0.all_connection_strings, "high", "unavailable")}"
#}
