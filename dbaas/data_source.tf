# Pull the state file of the existing Resource Manager stack (the network stack) into this context
data "oci_resourcemanager_stack_tf_state" "stack1_tf_state" {
  stack_id   = "${var.stack_id}"
  local_path = "stack1.tfstate"
}

# Load the pulled state file into a remote state data source
data "terraform_remote_state" "external_stack_remote_state" {
  backend = "local"
  config = {
    path = "${data.oci_resourcemanager_stack_tf_state.stack1_tf_state.local_path}"
  }
}

data oci_identity_availability_domains "ADs" {
  compartment_id = var.tenancy_ocid
}

# In case a DBCS instance is installed into an existing subnet we will use the attached bastion service
data "oci_bastion_bastions" "db_bastions" {
    compartment_id = local.db_compartment_id
    bastion_lifecycle_state = "ACTIVE"
    filter {
        name   = "target_subnet_id"
        values = [local.db_subnet_id]
  }
}
