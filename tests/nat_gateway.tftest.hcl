mock_provider "mgc" {}

variables {
  name = "test-vpc-nat"
}

run "verify_single_default_nat_gateway" {
  command = plan

  variables {
    enable_nat_gateway = true
  }

  assert {
    condition     = length(mgc_network_nat_gateway.this) == 1
    error_message = "Expected 1 default NAT Gateway"
  }

  assert {
    condition     = mgc_network_nat_gateway.this["default"].name == "test-vpc-nat-nat-gateway"
    error_message = "Default NAT Gateway name mismatch"
  }
}

run "verify_multi_az_nat_gateways" {
  command = plan

  variables {
    nat_gateways = {
      gw_a = {
        name              = "nat-gw-zone-a"
        description       = "NAT for AZ A"
        availability_zone = "br-ne1-a"
      }
      gw_b = {
        name              = "nat-gw-zone-b"
        description       = "NAT for AZ B"
        availability_zone = "br-ne1-b"
      }
    }
  }

  assert {
    condition     = length(mgc_network_nat_gateway.this) == 2
    error_message = "Expected 2 custom NAT Gateways"
  }

  assert {
    condition     = mgc_network_nat_gateway.this["gw_a"].availability_zone == "br-ne1-a"
    error_message = "NAT gw_a availability zone mismatch"
  }

  assert {
    condition     = mgc_network_nat_gateway.this["gw_b"].availability_zone == "br-ne1-b"
    error_message = "NAT gw_b availability zone mismatch"
  }
}
