locals {
    service             = "${var.owner}${var.project}"
    adbs_name           = "${local.service}adbs"
    adbs_display_name   = "${local.service} adbs"
    db_vcn_id           = try(data.oci_core_vcns.db_vcns.virtual_networks[0].id,var.vcn_id)
    nw_compartment_ocid = try(data.oci_identity_compartments.nw_compartments.compartments[0].id,var.nw_compartment_ocid)
    db_compartment_ocid = try(data.oci_identity_compartments.db_compartments.compartments[0].id,var.compartment_ocid)
    db_subnet_ocid      = try(data.oci_core_subnets.db_subnets.subnets[0].id,var.subnet_id)
    db_nsg_ocid         = try(data.oci_core_network_security_groups.db_network_security_groups.network_security_groups[0].id,var.nsg_id)
}