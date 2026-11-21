mock_provider "mgc" {}

variables {
  name = "test-vpc-validations"
}

run "reject_invalid_subnetpool_cidr" {
  command = plan

  variables {
    subnetpool_cidr = "not-a-valid-cidr"
  }

  expect_failures = [
    var.subnetpool_cidr
  ]
}

run "reject_invalid_subnet_ip_version" {
  command = plan

  variables {
    subnets = {
      bad_version = {
        cidr_block = "10.0.1.0/24"
        ip_version = "IPX"
      }
    }
  }

  expect_failures = [
    var.subnets
  ]
}

run "reject_route_missing_both_port_and_peering" {
  command = plan

  variables {
    routes = {
      missing_targets = {
        cidr_destination = "10.10.0.0/16"
      }
    }
  }

  expect_failures = [
    var.routes
  ]
}

run "reject_route_with_both_port_and_peering" {
  command = plan

  variables {
    routes = {
      ambiguous = {
        cidr_destination = "10.10.0.0/16"
        peering_id       = "11111111-1111-1111-1111-111111111111"
        port_id          = "22222222-2222-2222-2222-222222222222"
      }
    }
  }

  expect_failures = [
    var.routes
  ]
}

run "reject_route_with_invalid_uuid" {
  command = plan

  variables {
    routes = {
      invalid_uuid = {
        cidr_destination = "10.10.0.0/16"
        port_id          = "not-a-uuid"
      }
    }
  }

  expect_failures = [
    var.routes
  ]
}
