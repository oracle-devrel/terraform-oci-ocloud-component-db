# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# Query all primay ip vnics that belong to the DBCS instance
data "oci_core_private_ips" "db_private_ips_by_vnic" {
    depends_on = [
      oci_database_db_system.dbcs_db_system
    ]
    subnet_id = local.db_subnet_id
    filter {
      name   = "hostname_label"
      values = ["${local.db_system_hostname}.*"]
      regex = true
   }
    filter {
      name   = "is_primary"
      values = [true]
   }
}

output "dbnode_private_ip_addresses" {
    value = data.oci_core_private_ips.db_private_ips_by_vnic.private_ips[*].ip_address
}

resource "oci_bastion_session" "ssh" {
  count = length(data.oci_core_private_ips.db_private_ips_by_vnic.private_ips)
  bastion_id                                   = local.db_bastion_id
  key_details {
    public_key_content                         = var.db_system_ssh_public_keys
  }
  target_resource_details {
    session_type                               = "PORT_FORWARDING"
    target_resource_id                         = ""
    target_resource_operating_system_user_name = "opc"
    target_resource_port                       = 22
    target_resource_private_ip_address         = data.oci_core_private_ips.db_private_ips_by_vnic.private_ips[count.index].ip_address
  }
  display_name                                 = "${data.oci_core_private_ips.db_private_ips_by_vnic.private_ips[count.index].hostname_label}_ssh"
  key_type                                     = "PUB"
  session_ttl_in_seconds                       = 1800
}

resource "oci_bastion_session" "sqlnet" {
  count = length(data.oci_core_private_ips.db_private_ips_by_vnic.private_ips)
  bastion_id                                   = local.db_bastion_id
  key_details {
    public_key_content                         = var.db_system_ssh_public_keys
  }
  target_resource_details {
    session_type                               = "PORT_FORWARDING"
    target_resource_id                         = ""
    target_resource_port                       = 1521
    target_resource_private_ip_address         = data.oci_core_private_ips.db_private_ips_by_vnic.private_ips[count.index].ip_address
  }
  display_name                                 = "${data.oci_core_private_ips.db_private_ips_by_vnic.private_ips[count.index].hostname_label}_sqlnet"
  key_type                                     = "PUB"
  session_ttl_in_seconds                       = 1800
}

# resource "oci_bastion_session" "em" {
#   count = length(data.oci_core_private_ips.db_private_ips_by_vnic.private_ips)
#   bastion_id                                   = local.db_bastion_id
#   key_details {
#     public_key_content                         = var.db_system_ssh_public_keys
#   }
#   target_resource_details {
#     session_type                               = "PORT_FORWARDING"
#     target_resource_id                         = ""
#     target_resource_port                       = 5500
#     target_resource_private_ip_address         = data.oci_core_private_ips.db_private_ips_by_vnic.private_ips[count.index].ip_address
#   }
#   display_name                                 = "${data.oci_core_private_ips.db_private_ips_by_vnic.private_ips[count.index].hostname_label}_em"
#   key_type                                     = "PUB"
#   session_ttl_in_seconds                       = 10800
# }