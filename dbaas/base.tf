# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

// --- network domain ---
module "db_domain" {
  source = "github.com/oracle-devrel/terraform-oci-ocloud-landing-zone/component/network_domain"
  count = local.create_subnet
  config  = {
    tenancy_id     = var.tenancy_ocid
    compartment_id = local.db_compartment_id
    vcn_id         = local.db_vcn_id
    anywhere       = data.terraform_remote_state.external_stack_remote_state.outputs.net_segment_1_anywhere
    display_name   = "${local.service_name}_db_client"
    dns_label      = "${local.service_label}db"
    defined_tags   = null
    freeform_tags  = {"framework" = "ocloud"}
  }
  subnet  = {
    cidr_block                  = cidrsubnet(data.terraform_remote_state.external_stack_remote_state.outputs.net_segment_1_subnets.db,1,0)
    prohibit_public_ip_on_vnic  = true
    dhcp_options_id             = null
    route_table_id              = data.terraform_remote_state.external_stack_remote_state.outputs.net_segment_1_osn_route_id.id
  }
  bastion  = {
    create            = true # Determine whether a bastion service will be deployed and attached
    client_allow_cidr = [ data.terraform_remote_state.external_stack_remote_state.outputs.net_segment_1_anywhere ]
    #max_session_ttl   = 1800
    max_session_ttl   = 10800
  }
  tcp_ports = {
    // [protocol, source_cidr, destination port min, max]
    ingress  = [
      ["ssh",   data.terraform_remote_state.external_stack_remote_state.outputs.net_segment_1_anywhere,  22,  22], 
      ["http",  data.terraform_remote_state.external_stack_remote_state.outputs.net_segment_1_anywhere,  80,  80], 
      ["https", data.terraform_remote_state.external_stack_remote_state.outputs.net_segment_1_anywhere, 443, 443],
      ["tcp", data.terraform_remote_state.external_stack_remote_state.outputs.net_segment_1_anywhere, 1521, 1522],
      ["tcp", data.terraform_remote_state.external_stack_remote_state.outputs.net_segment_1_anywhere, 5500, 5500]
    ]
  }
}

// --- db domain output ---
#output "db_domain_subnet"        { value = module.db_domain.subnet }
#output "db_domain_security_list" { value = module.db_domain.seclist }
#output "db_domain_bastion"       { value = module.db_domain.bastion }