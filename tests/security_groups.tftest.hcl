mock_provider "mgc" {}

variables {
  name = "test-vpc-sg"

  security_groups = {
    web = {
      description           = "Web tier security group"
      disable_default_rules = false
      rules = {
        http = {
          description      = "Allow HTTP"
          direction        = "ingress"
          ethertype        = "IPv4"
          protocol         = "tcp"
          port_range_min   = 80
          port_range_max   = 80
          remote_ip_prefix = "0.0.0.0/0"
        }
        https = {
          description      = "Allow HTTPS"
          direction        = "ingress"
          ethertype        = "IPv4"
          protocol         = "tcp"
          port_range_min   = 443
          port_range_max   = 443
          remote_ip_prefix = "0.0.0.0/0"
        }
      }
    }
    db = {
      description           = "Database tier security group"
      disable_default_rules = true
      rules = {
        postgres = {
          description      = "PostgreSQL from internal network"
          direction        = "ingress"
          ethertype        = "IPv4"
          protocol         = "tcp"
          port_range_min   = 5432
          port_range_max   = 5432
          remote_ip_prefix = "10.0.0.0/16"
        }
      }
    }
  }
}

run "verify_security_groups_and_rules" {
  command = plan

  assert {
    condition     = length(mgc_network_security_groups.this) == 2
    error_message = "Expected 2 security groups to be planned"
  }

  assert {
    condition     = length(mgc_network_security_groups_rules.this) == 3
    error_message = "Expected 3 flattened security group rules"
  }

  assert {
    condition     = mgc_network_security_groups.this["web"].description == "Web tier security group"
    error_message = "Web security group description mismatch"
  }

  assert {
    condition     = mgc_network_security_groups.this["db"].disable_default_rules == true
    error_message = "DB security group disable_default_rules should be true"
  }
}
