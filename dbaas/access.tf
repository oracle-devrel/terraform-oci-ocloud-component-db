# In order to create bastion sessions query dbnodes and its ip addresses
data "oci_database_db_nodes" "dbaas_db_nodes" {
    compartment_id = local.db_compartment_id
    db_system_id = oci_database_db_system.dbaas_db_system.id
    state = "AVAILABLE"
}

# output "dbaas_db_nodes" {
#   value = data.oci_database_db_nodes.dbaas_db_nodes.db_nodes[*].db_node_id
# }

data "oci_core_private_ips" "db_private_ips_by_vnic" {
     count = local.db_system_node_count
     vnic_id = data.oci_database_db_nodes.dbaas_db_nodes.db_nodes[count.index].vnic_id
}

# output "dbaas_db_nodes_vnics" {
#      value = data.oci_core_private_ips.db_private_ips_by_vnic
# }

resource "oci_bastion_session" "ssh" {
  count = local.db_system_node_count
  bastion_id                                   = local.db_bastion_id
  key_details {
    public_key_content                         = var.db_system_ssh_public_keys
  }
  target_resource_details {
    session_type                               = "PORT_FORWARDING"
    target_resource_id                         = ""
    target_resource_operating_system_user_name = "opc"
    target_resource_port                       = 22
    target_resource_private_ip_address         = data.oci_core_private_ips.db_private_ips_by_vnic[count.index].private_ips[0].ip_address
  }
  display_name                                 = "${data.oci_database_db_nodes.dbaas_db_nodes.db_nodes[count.index].hostname}_ssh"
  key_type                                     = "PUB"
  session_ttl_in_seconds                       = 1800
}

resource "oci_bastion_session" "sqlnet" {
  count = local.db_system_node_count
  bastion_id                                   = local.db_bastion_id
  key_details {
    public_key_content                         = var.db_system_ssh_public_keys
  }
  target_resource_details {
    session_type                               = "PORT_FORWARDING"
    target_resource_id                         = ""
    target_resource_port                       = 1521
    target_resource_private_ip_address         = data.oci_core_private_ips.db_private_ips_by_vnic[count.index].private_ips[0].ip_address
  }
  display_name                                 = "${data.oci_database_db_nodes.dbaas_db_nodes.db_nodes[count.index].hostname}_sqlnet"
  key_type                                     = "PUB"
  session_ttl_in_seconds                       = 1800
}