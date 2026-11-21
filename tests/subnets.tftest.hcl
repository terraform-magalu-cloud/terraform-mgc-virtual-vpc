mock_provider "mgc" {}

variables {
  name            = "test-vpc-subnets"
  subnetpool_cidr = "172.16.0.0/16"

  subnets = {
    public_a = {
      cidr_block        = "172.16.1.0/24"
      availability_zone = "br-ne1-a"
      description       = "Public Subnet AZ A"
      dns_nameservers   = ["1.1.1.1", "1.0.0.1"]
    }
    private_a = {
      cidr_block        = "172.16.2.0/24"
      availability_zone = "br-ne1-a"
      description       = "Private Subnet AZ A"
    }
    public_b = {
      cidr_block        = "172.16.3.0/24"
      availability_zone = "br-ne1-b"
      description       = "Public Subnet AZ B"
    }
  }
}

run "verify_subnets_creation" {
  command = plan

  assert {
    condition     = length(mgc_network_vpcs_subnets.this) == 3
    error_message = "Expected 3 subnets to be planned"
  }

  assert {
    condition     = mgc_network_vpcs_subnets.this["public_a"].cidr_block == "172.16.1.0/24"
    error_message = "public_a CIDR block mismatch"
  }

  assert {
    condition     = mgc_network_vpcs_subnets.this["public_a"].availability_zone == "br-ne1-a"
    error_message = "public_a AZ mismatch"
  }

  assert {
    condition     = mgc_network_vpcs_subnets.this["public_a"].dns_nameservers[0] == "1.1.1.1" && mgc_network_vpcs_subnets.this["public_a"].dns_nameservers[1] == "1.0.0.1"
    error_message = "public_a custom DNS nameservers mismatch"
  }

  assert {
    condition     = mgc_network_vpcs_subnets.this["private_a"].dns_nameservers[0] == "8.8.8.8" && mgc_network_vpcs_subnets.this["private_a"].dns_nameservers[1] == "8.4.4.4" || mgc_network_vpcs_subnets.this["private_a"].dns_nameservers[1] == "8.8.4.4"
    error_message = "private_a default DNS nameservers mismatch"
  }
}
