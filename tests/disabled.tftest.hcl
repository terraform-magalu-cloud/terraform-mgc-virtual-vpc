mock_provider "mgc" {}

variables {
  name   = "disabled-vpc"
  create = false
}

run "verify_zero_resources_when_disabled" {
  command = plan

  assert {
    condition     = length(mgc_network_vpcs.this) == 0
    error_message = "No VPC should be planned when create = false"
  }

  assert {
    condition     = length(mgc_network_subnetpools.this) == 0
    error_message = "No Subnet Pool should be planned when create = false"
  }

  assert {
    condition     = length(mgc_network_vpcs_subnets.this) == 0
    error_message = "No Subnets should be planned when create = false"
  }

  assert {
    condition     = length(mgc_network_nat_gateway.this) == 0
    error_message = "No NAT Gateway should be planned when create = false"
  }

  assert {
    condition     = length(mgc_network_security_groups.this) == 0
    error_message = "No Security Groups should be planned when create = false"
  }

  assert {
    condition     = length(mgc_network_public_ips.this) == 0
    error_message = "No Public IPs should be planned when create = false"
  }

  assert {
    condition     = output.vpc_id == null
    error_message = "vpc_id output should be null when create = false"
  }
}
