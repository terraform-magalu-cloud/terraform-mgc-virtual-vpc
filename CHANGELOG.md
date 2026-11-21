# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2026-11-20

### Features

* **vpc:** initial release of the Magalu Cloud VPC module (`terraform-mgc-virtual-vpc`)
* **subnetpool:** automatic dedicated subnet pool creation with `/16` CIDR, custom subnet pool ID support, and tenant default fallback
* **subnets:** dynamic multi-AZ subnet management with custom CIDRs, DNS nameservers, and IPv4/IPv6 support
* **nat-gateway:** outbound internet connectivity for private subnets with automatic availability zone inference
* **security-groups:** granular virtual firewall security group management with ingress and egress rules
* **routes:** custom VPC route table management for VPC Peering and Network Interface Ports (`port_id`)
* **public-ips:** allocation and management of public IPs attached to the VPC
* **tags:** support for attaching Magalu Cloud tags (`mgc_tag_attachment`) to the VPC
* **validations:** native Terraform validations for CIDR formats, IP versions, UUIDs, firewall rule directions, and MGC-compliant descriptions
* **testing:** complete native `terraform test` unit test suite with 12 assertions across 7 test files (100% offline, 0 cloud cost)
* **examples:** provided ready-to-run `examples/simple` and `examples/complete` configurations
* **ci-cd:** added `Makefile` (`make test`, `make fmt`, `make validate`, `make all`) and GitHub Actions workflows for automated tests, PR title validation, pre-commit, Telegram notifications, and Semantic Release
