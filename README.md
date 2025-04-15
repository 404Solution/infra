# 🏗️ AWS Infrastructure as Code Framework

Welcome to the **404Solution/infra** repository — a robust, modular, and scalable Infrastructure as Code (IaC) framework designed for provisioning and managing AWS resources using **Terraform** and **Terragrunt**.

---

## 📐 Overview

This repository provides a structured approach to managing AWS infrastructure with reusable modules and environment-specific configurations.

---

## 🗂️ Repository Structure

```bash
infra/
├── environments/
│   ├── dev/
│   ├── staging/
│   └── prod/
├── modules/
│   ├── vpc/
│   ├── ec2/
│   ├── rds/
│   └── ...
├── terragrunt.hcl
└── README.md
```

---

## 🚀 Getting Started

### ✅ Prerequisites

Ensure you have the following tools installed:

- **Terraform** ≥ 1.0
- **Terragrunt** ≥ 0.35
- **AWS CLI** (configured with appropriate credentials)

---

### 📦 Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/404Solution/infra.git
   cd infra
   ```

2. Navigate to the desired environment:

   ```bash
   cd environments/dev
   ```

3. Initialize and apply the configuration:

   ```bash
   terragrunt init
   terragrunt apply
   ```

---

## 🧱 Modules

The repository includes the following Terraform modules:

- **VPC**: Creates a Virtual Private Cloud with subnets, route tables, gateways, and NAT.
- **EC2**: Launches EC2 instances with custom configuration and user data support.
- **RDS**: Provisions managed relational databases.
- **Security Groups**: Creates reusable and composable security group configurations.
- **ALB (optional)**: For deploying Application Load Balancers.
- **SSM (optional)**: To enable Session Manager access to instances without SSH.

Each module is designed to be reusable, customizable via input variables, and version-controlled.

---

## 🌍 Environments

This project uses **Terragrunt** to define and manage separate environments:

- **`dev/`**: Development environment
- **`staging/`**: Staging/pre-production
- **`prod/`**: Production environment

Each environment folder contains its own `terragrunt.hcl` file that specifies:

- Module source location
- Input variables
- Remote backend configuration (e.g., S3 & DynamoDB for locking)

---

## 🔄 Workflow

1. Navigate to the environment you wish to deploy:

   ```bash
   cd environments/dev
   ```

2. Preview the infrastructure changes:

   ```bash
   terragrunt plan
   ```

3. Apply the infrastructure:

   ```bash
   terragrunt apply
   ```

4. Destroy the infrastructure (if needed):

   ```bash
   terragrunt destroy
   ```

---

## ✅ Best Practices

- **Use Remote Backends**: Store Terraform state in an S3 bucket with DynamoDB locking to avoid conflicts.
- **Split by Environment**: Keep configurations for dev, staging, and prod separate.
- **Modularize Everything**: Use Terraform modules to abstract logic and reuse code across projects.
- **Secure Your Secrets**: Never store secrets in code. Use SSM, Secrets Manager, or environment variables.
- **Tag Resources**: Apply consistent tagging across AWS resources for cost tracking and organization.
- **Pin Versions**: Lock module and provider versions to ensure reproducible infrastructure.

---

## 📄 License

This project is licensed under the **MIT License**.

---

## 📚 Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [Terragrunt Documentation](https://terragrunt.gruntwork.io/docs)
- [AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Gruntwork Terraform Reference Architecture](https://gruntwork.io/terraform-best-practices/)