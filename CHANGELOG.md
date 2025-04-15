# Changelog

All notable changes to this project will be documented in this file.
This format is based on [Keep a Changelog](https://keepachangelog.com/)
and this project adheres to [Semantic Versioning](https://semver.org/).

---

## [1.0.0] - 2025-04-15

Initial version of the **infra** repository.
Includes the basic Terragrunt and Terraform setup for:
- HA-VPC
- Subnet module
- `remote backend` configuration (S3 with LOCK) for Terraform state in the new version
- Initial documentation in `README.md`
