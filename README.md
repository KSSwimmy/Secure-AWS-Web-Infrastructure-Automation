# Secure AWS Web Infrastructure Automation

## 📖 Project Overview
This project was built to solve a specific business problem for a fast-growing B2B SaaS startup. The client required a highly secure, reliable, and proactively monitored web server deployed in the cloud, with comprehensive documentation to allow their internal development team to take over maintenance.

**Goal:** Architect and deploy a hardened Linux web server in AWS using Infrastructure as Code (IaC), enforce least-privilege access, and establish proactive monitoring.

## 🛠️ Technologies Used
* **Cloud Provider:** Amazon Web Services (AWS)
* **Infrastructure as Code:** Terraform
* **OS:** Ubuntu Linux
* **Web Server:** Nginx / Apache *(Update this once we pick one!)*
* **Security:** AWS Security Groups, IAM, SSH Key-Based Authentication, UFW (Uncomplicated Firewall)
* **Monitoring:** AWS CloudWatch *(To be implemented)*

## 🏗️ Architecture & Security Implementation
To meet the client's strict security requirements, this infrastructure was built with a "Security-First" approach:
1. **Network Isolation:** Resources are deployed within a dedicated Virtual Private Cloud (VPC).
2. **Strict Firewall Rules:** Security Groups configured to only allow HTTP/HTTPS traffic from the public web, and SSH access restricted to authorized administrator IPs.
3. **Hardened Compute:** EC2 instance configured to disable root password logins, enforcing cryptographic SSH keys.

## 🚀 Deployment Instructions (Runbook)
*(Note: This section acts as the official SOP for the client's internal team)*

### Prerequisites
* AWS CLI installed and authenticated
* Terraform installed globally

### Steps to Deploy
1. Clone this repository to your local machine.
2. Navigate to the project directory.
3. Initialize the Terraform working directory:
   `terraform init`
4. Review the infrastructure plan:
   `terraform plan`
5. Deploy the resources to AWS:
   `terraform apply -auto-approve`

## 📈 Monitoring & Alerts
*(Screenshots of CloudWatch dashboard and CPU alerts will go here once completed in Phase 4)*
.