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
    # Set the landing zones VNC. I case the database is placed in an existing subnet use the input value 
    db_vcn_id = try(data.terraform_remote_state.external_stack_remote_state.outputs.service_segment_vcn_id,var.vcn_id)
    # Set the databases target compartment. In case the database is placed in an existing subnet use the input value
    db_compartment_id = try(data.terraform_remote_state.external_stack_remote_state.outputs.db_compartment_id,var.db_compartment_id)
    # Set the target subnet
    db_subnet_id = var.use_existing_subnet ? var.subnet_id : module.db_domain[0].subnet.id
    # Create a new subnet before deploying a DB instance or add the resource into an existing subnet
    create_subnet = var.use_existing_subnet ? 0 : 1
    # By default a security list is used to control the traffice from or to the database subnet. Optionally a network security group can be selected
    db_nsg_id = length(var.db_system_nsg_id) > 0 ? tolist(var.db_system_nsg_id) : null
    # Match configuration templates to VM Shapes and DB storage
    db_system_shape = var.db_config == "Small" ? var.db_basic_config["small"].system_shape : var.db_config == "Medium" ? var.db_basic_config["medium"].system_shape : var.db_config == "Large" ? var.db_basic_config["large"].system_shape : var.db_system_shape
    db_system_data_storage_size_in_gb = var.db_config == "Small" ? var.db_basic_config["small"].storage_size_in_gb : var.db_config == "Medium" ? var.db_basic_config["small"].storage_size_in_gb : var.db_config == "Large" ? var.db_basic_config["small"].storage_size_in_gb : var.db_system_data_storage_size_in_gb

    #  2-node RAC DB systems requires ENTERPRISE_EDITION_EXTREME_PERFORMANCE edition and ASM
    db_system_node_count = var.deployment_type == "Cluster" ? 2 : var.db_system_node_count
    db_system_database_edition = local.db_system_node_count > 1 ? "ENTERPRISE_EDITION_EXTREME_PERFORMANCE" : var.db_system_database_edition
    db_system_db_system_options_storage_management = local.db_system_node_count > 1 || var.deployment_type == "Basic" ? "ASM" : var.deployment_type == "Fast Provisioning" ? "LVM" : var.db_system_db_system_options_storage_management
    # In case cluster name isn't set explicitly set it to <service label>-cluster. Note cluster name may not exceed 11 characters
    db_system_cluster_name = local.db_system_node_count > 1 && length(var.db_system_cluster_name) == 0 ? "${local.service_label}rac" : var.db_system_cluster_name
    # For Deployment Type Fast Provioning disable automated backups else enable it
    db_system_db_home_database_db_backup_config_auto_backup_enabled = var.deployment_type == "Fast Provisioning" ? false : var.deployment_type == "Fast Provisioning" || var.deployment_type == "Cluster" ? true : var.db_system_db_home_database_db_backup_config_auto_backup_enabled
    # database nodes in the same subnet may not use the same hostname prefix. Adding the project label makes it unique to some extent
    db_system_hostname = format("%s%s",var.db_system_hostname,local.project)
    # db_bastion_id = local.create_subnet == 1 ? (
    #     module.db_domain[0].bastion.id : length(data.oci_bastion_bastions.db_bastions.bastions) > 0 ? (
    #         data.oci_bastion_bastions.db_bastions.bastions[0].id : null))
    # By default we use the Bastion Service that is instanciated through the landing zone. Only use the "local" Bastion if bastion create was set to true (See network.tf)
    db_bastion_id = module.db_domain[0].bastion == null ? data.terraform_remote_state.external_stack_remote_state.outputs.app_domain_bastion.id : module.db_domain[0].bastion.id

    # By default DB Stack uses the same resource name prefix as the realted landing zone.
    # Set var.overwrite_project to true to overwrite organization, project and environment
    organization = var.overwrite_project ? var.organization : split("_", data.oci_identity_compartment.init_name.name)[0]
    project = var.overwrite_project ? var.organization : split("_", data.oci_identity_compartment.init_name.name)[1]
    environment = var.overwrite_project ? var.organization : split("_", data.oci_identity_compartment.init_name.name)[2]
    # Change to 
    # service_label = format("%s%s", lower(substr(local.project, 0, 5)), lower(substr(local.environment, 0, 3)))
    # ?
    # service_label used to name db resource parameters
    service_label = format("%s%s", lower(substr(local.organization, 0, 3)), lower(substr(local.project, 0, 5)))
}



