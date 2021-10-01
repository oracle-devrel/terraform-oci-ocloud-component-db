# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# Default configurations
# Small Configuration
# db_system_shape = VM.Standard2.2
# db_system_data_storage_size_in_gb = 512

# Medium Configuration
# db_system_shape = VM.Standard2.8
# db_system_data_storage_size_in_gb = 4096

# Medium Configuration
# db_system_shape = VM.Standard2.16
# db_system_data_storage_size_in_gb = 8192

locals {
    db_vcn_id = try(data.terraform_remote_state.external_stack_remote_state.outputs.net_segment_1_vcn.id,var.vcn_id)
    db_compartment_id = try(data.terraform_remote_state.external_stack_remote_state.outputs.db_compartment.id,var.db_compartment_id)
    db_subnet_id = var.use_existing_subnet ? var.subnet_id : module.db_domain[0].subnet.id
    # Create a new subnet before deploying a DB instance or add the resource into an existing subnet
    create_subnet = var.use_existing_subnet ? 0 : 1
    db_nsg_id = length(var.db_system_nsg_id) > 0 ? tolist(var.db_system_nsg_id) : null
    db_system_shape = var.db_config == "Small" ? "VM.Standard2.2" : var.db_config == "Medium" ? "VM.Standard2.8" : var.db_config == "Large" ? "VM.Standard2.16" : var.db_system_shape
    db_system_data_storage_size_in_gb = var.db_config == "Small" ? 512 : var.db_config == "Medium" ? 4096 : var.db_config == "Large" ? 8192 : var.db_system_data_storage_size_in_gb

    #  2-node RAC DB systems requires ENTERPRISE_EDITION_EXTREME_PERFORMANCE edition and ASM
    db_system_node_count = var.deployment_type == "Cluster" ? 2 : var.db_system_node_count
    db_system_database_edition = local.db_system_node_count > 1 ? "ENTERPRISE_EDITION_EXTREME_PERFORMANCE" : var.db_system_database_edition
    db_system_db_system_options_storage_management = local.db_system_node_count > 1 || var.deployment_type == "Basic" ? "ASM" : var.deployment_type == "Fast Provisioning" ? "LVM" : var.db_system_db_system_options_storage_management
    # In case cluster name isn't set explicitly set it to <service label>-cluster. Note cluster name may not exceed 11 characters
    db_system_cluster_name = local.db_system_node_count > 1 && length(var.db_system_cluster_name) == 0 ? "${local.service_label}rac" : var.db_system_cluster_name
    # For Deployment Type Fast Provioning disable automated backups else enable it
    db_system_db_home_database_db_backup_config_auto_backup_enabled = var.deployment_type == "Fast Provisioning" ? false : var.deployment_type == "Fast Provisioning" || var.deployment_type == "Cluster" ? true : var.db_system_db_home_database_db_backup_config_auto_backup_enabled
    # database nodes in the same subnet may not use the same hostname prefix. Adding the project label makes it unique to some extent
    db_system_hostname = format("%s%s",var.db_system_hostname,var.project)
    # In case a DBCS instance is installed into an existing subnet we will use the existing bastion service to attach the sessions
    db_bastion_id = local.create_subnet == 1 ? module.db_domain[0].bastion.id : length(data.oci_bastion_bastions.db_bastions.bastions) > 0 ? data.oci_bastion_bastions.db_bastions.bastions[0].id : null
}



