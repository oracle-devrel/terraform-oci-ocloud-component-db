data "oci_identity_compartments" "nw_compartments" {
  #Required
  compartment_id = var.tenancy_ocid

  #Optional
  name              = "${local.service}-network-cmp"
  compartment_id_in_subtree = true
  state                     = "ACTIVE"
}

data "oci_identity_compartments" "db_compartments" {
  #Required
  compartment_id = var.tenancy_ocid

  #Optional
  name                      = "${local.service}-database-cmp"
  compartment_id_in_subtree = true
  state                     = "ACTIVE"
}

data "oci_core_vcns" "db_vcns" {
  #Required
  compartment_id = local.nw_compartment_ocid

  #Optional
  display_name              = "${local.service}-0-vcn"
  state                     = "AVAILABLE"
}

data "oci_core_subnets" "db_subnets" {
  #Required
  compartment_id = local.nw_compartment_ocid

  #Optional
  display_name = "${local.service}-0-db-subnet"
  state = "AVAILABLE"
}

data "oci_core_network_security_groups" "db_network_security_groups" {
  #Optional
  compartment_id = local.nw_compartment_ocid
  display_name = "${local.service}-0-vcn-db-nsg"
  state = "AVAILABLE"
}

# lndzntst-database-cmp
# lndzntst-0-vcn
# lndzntst-0-db-subnet
# lndzntst-0-vcn-db-nsg