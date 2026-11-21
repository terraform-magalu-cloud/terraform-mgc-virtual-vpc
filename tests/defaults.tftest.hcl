mock_provider "mgc" {}

variables {
  name = "test-vpc-defaults"
}

run "defaults_create_vpc_and_subnetpool" {
  command = plan

  assert {
    condition     = length(mgc_network_vpcs.this) == 1
    error_message = "VPC should be created"
  }

  assert {
    condition     = mgc_network_vpcs.this[0].name == "test-vpc-defaults"
    error_message = "VPC name should match input variable"
  }

  assert {
    condition     = length(mgc_network_subnetpools.this) == 1
    error_message = "Subnet pool should be created by default"
  }

  assert {
    condition     = mgc_network_subnetpools.this[0].cidr == "10.0.0.0/16"
    error_message = "Default subnet pool CIDR should be 10.0.0.0/16"
  }

  assert {
    condition     = length(mgc_network_vpcs_subnets.this) == 0
    error_message = "No subnets should be created by default"
  }

  assert {
    condition     = length(mgc_network_nat_gateway.this) == 0
    error_message = "NAT Gateway should not be created by default"
  }

  assert {
    condition     = length(mgc_network_security_groups.this) == 0
    error_message = "No security groups should be created by default"
  }
}
