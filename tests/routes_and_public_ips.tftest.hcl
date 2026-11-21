mock_provider "mgc" {}

variables {
  name = "test-vpc-routes"

  routes = {
    to_peering = {
      cidr_destination = "192.168.0.0/16"
      description      = "Route to peered VPC"
      peering_id       = "11111111-1111-1111-1111-111111111111"
    }
    to_appliance = {
      cidr_destination = "172.16.0.0/12"
      description      = "Route to virtual appliance port"
      port_id          = "22222222-2222-2222-2222-222222222222"
    }
  }

  public_ips = {
    ingress_ip = {
      description = "Public IP for ingress controller"
    }
  }
}

run "verify_routes_and_public_ips" {
  command = plan

  assert {
    condition     = length(mgc_network_vpcs_route.this) == 2
    error_message = "Expected 2 routes to be planned"
  }

  assert {
    condition     = mgc_network_vpcs_route.this["to_peering"].peering_id == "11111111-1111-1111-1111-111111111111"
    error_message = "peering_id mismatch on to_peering route"
  }

  assert {
    condition     = mgc_network_vpcs_route.this["to_appliance"].port_id == "22222222-2222-2222-2222-222222222222"
    error_message = "port_id mismatch on to_appliance route"
  }

  assert {
    condition     = length(mgc_network_public_ips.this) == 1
    error_message = "Expected 1 public IP to be planned"
  }
}
