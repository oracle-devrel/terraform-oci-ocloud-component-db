data "oci_database_db_nodes" "dbaas_db_nodes" {
    compartment_id = local.db_compartment_id
    db_system_id = oci_database_db_system.dbaas_db_system.id
    state = "AVAILABLE"
}

output "dbaas_db_nodes" {
  value = data.oci_database_db_nodes.dbaas_db_nodes.db_nodes[*].db_node_id
}

data "oci_core_private_ips" "db_private_ips_by_vnic" {
     vnic_id = data.oci_database_db_nodes.dbaas_db_nodes.db_nodes[0].vnic_id
}

# output "dbaas_db_nodes_vnics" {
#     value = data.oci_core_private_ips.db_private_ips_by_vnic
# }


resource "oci_bastion_session" "ssh" {
  bastion_id                                   = length(module.db_domain[0].bastion) > 0 ? module.db_domain[0].bastion.id : null
  key_details {
    public_key_content                         = var.db_system_ssh_public_keys
  }
  target_resource_details {
    session_type                               = "PORT_FORWARDING"
    target_resource_id                         = ""
    target_resource_operating_system_user_name = "opc"
    target_resource_port                       = 22
    target_resource_private_ip_address         = data.oci_core_private_ips.db_private_ips_by_vnic.private_ips[0].ip_address
  }
  display_name                                 = "${data.oci_database_db_nodes.dbaas_db_nodes.db_nodes[0].hostname}_ssh"
  key_type                                     = "PUB"
  session_ttl_in_seconds                       = 1800
}


# resource "oci_bastion_session" "ssh" {
#   #count                                        = var.session.enable == true ? 1 : 0
#   bastion_id                                   = length( module.db_domain.bastion) > 0 ? data.oci_bastion_bastions.host.bastions[0].id : null
#   key_details {
#     public_key_content                         = [var.db_system_ssh_public_keys]
#   }
#   target_resource_details {
#     session_type                               = "PORT_FORWARDING"
#     target_resource_id                         = oci_core_instance.instance[0].id
#     target_resource_port                       = 1521
#     target_resource_private_ip_address         = oci_core_instance.instance[0].private_ip
#   }
#   display_name                                 = "${var.config.display_name}_sql"
#   key_type                                     = "PUB"
#   session_ttl_in_seconds                       = var.session.ttl_in_seconds
# }