# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

// --- database tier --- //
module "db_domain" {
  depends_on = [
    data.oci_identity_compartments.init,
    data.terraform_remote_state.external_stack_remote_state
  ]
  source = "github.com/oracle-devrel/terraform-oci-ocloud-landing-zone/component/network_domain"
  # use release branch
  #source = "github.com/oracle-devrel/terraform-oci-ocloud-landing-zone//component/network_domain?ref=release"
  count = local.create_subnet
  config  = {
    service_id     = data.oci_identity_compartments.init.compartments[0].compartment_id
    compartment_id = local.db_compartment_id
    vcn_id         = local.db_vcn_id
    anywhere       = data.terraform_remote_state.external_stack_remote_state.outputs.service_segment_anywhere
    defined_tags   = null
    freeform_tags  = {"framework" = "ocloud"}
  }
  # Subnet Reuirements
  # DB System Type, # Required IP Addresses, Minimum Subnet Size
  # 1-node virtual machine, 1 + 3 reserved in subnet = 4, /30 (4 IP addresses)
  # 2-node RAC virtual machine, (2 addresses * 2 nodes) + 3 for SCANs + 3 reserved in subnet = 10, /28 (16 IP addresses)
  subnet  = {
    # Select the predefined name per index. This will assign the entire allocated subnet CIDIR to the DB subnet.
    domain                      = "db"
    
    # Select the predefined range per index. This will assign the entire allocated subnet CIDIR to the DB subnet.
    # Alternatively use cidrsubnet() to cut out a smaller subnet, i.e.
    # cidr_block = cidrsubnet(element(values(data.terraform_remote_state.external_stack_remote_state.outputs.service_segment_subnets), 1),newbit,netnum)
    # Example:
    #     > cidrsubnets("10.0.0.128/26",2,2,2,2)
    # tolist([
    #   "10.0.0.128/28",  --->  cidrsubnet("10.0.0.128/26",2,0)
    #   "10.0.0.144/28",  --->  cidrsubnet("10.0.0.128/26",2,1)
    #   "10.0.0.160/28",  --->  cidrsubnet("10.0.0.128/26",2,2)
    #   "10.0.0.176/28",  --->  cidrsubnet("10.0.0.128/26",2,3)
    # ]) 
    # For further details refer to https://www.terraform.io/docs/language/functions/cidrsubnet.html
    cidr_block                  =  lookup(data.terraform_remote_state.external_stack_remote_state.outputs.service_segment_subnets, "db", "This CIDR is not defined")
    prohibit_public_ip_on_vnic  = true
    dhcp_options_id             = null
    route_table_id              = data.terraform_remote_state.external_stack_remote_state.outputs.service_segment_osn_route_id
  }
  bastion  = {
    # Database domain leverages the app domain's Bastion Service
    create            = false
    client_allow_cidr = []
    max_session_ttl   = null
  }
  tcp_ports = {
    // [protocol, source_cidr, destination port min, max]
    ingress  = [
      ["ssh",   data.terraform_remote_state.external_stack_remote_state.outputs.service_segment_anywhere,  22,  22], 
      ["http",  data.terraform_remote_state.external_stack_remote_state.outputs.service_segment_anywhere,  80,  80], 
      ["https", data.terraform_remote_state.external_stack_remote_state.outputs.service_segment_anywhere, 443, 443],
      ["tcp", data.terraform_remote_state.external_stack_remote_state.outputs.service_segment_anywhere, 1521, 1522],
      ["tcp", data.terraform_remote_state.external_stack_remote_state.outputs.service_segment_anywhere, 5500, 5500],
      ["tcp", data.terraform_remote_state.external_stack_remote_state.outputs.service_segment_anywhere, 6200, 6200]
    ]
  }
}

# output "db_domain_subnet"        { value = module.db_domain[0].subnet_id }
# output "db_domain_security_list" { value = module.db_domain[0].seclist_id }
output "db_domain_subnet"        { value = local.db_subnet_id }
# output "db_domain_security_list" { value = module.db_domain[0].seclist_id }
// --- database tier --- //