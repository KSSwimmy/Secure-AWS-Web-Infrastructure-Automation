# 🚀 Secure AWS Web Infrastructure Automation

## 👋 Hey there! Project Overview
I am **SO FREAKING EXCITED** to share this project! If you know me, you know my absolute favorite place to be is joyfully behind a computer screen, bringing order and reliability to digital chaos ✨.

This project was built to solve a real-world business problem for a fast-growing B2B SaaS startup. They needed a highly secure, reliable, and proactively monitored web server deployed in the cloud. My goal? Architect and deploy a hardened Linux web server in AWS using Infrastructure as Code (IaC), enforce least-privilege access, and write the beautiful, easy-to-read documentation that internal teams actually *want* to use to take over maintenance!

## 🛠️ The Tech Stack
As a fellow DIY-er and infrastructure nerd, I chose these specific tools for their power and cost-effectiveness:
*   ☁️ **Cloud Provider:** Amazon Web Services (AWS)
*   🏗️ **Infrastructure as Code:** Terraform
*   🐧 **OS:** Ubuntu Linux 22.04 LTS
*   🌐 **Web Server:** Nginx (managed via `systemd`)
*   🔒 **Security:** AWS Security Groups, IAM, SSH Key-Based Authentication

## 🏰 Architecture & Security Implementation
To meet strict security requirements, I built this with a major "Security-First" approach:
1.  **Network Isolation:** Everything lives securely inside a dedicated Virtual Private Cloud (VPC).
2.  **Strict Firewall Rules:** Security Groups are locked down to only allow HTTP traffic from the public web, and SSH access is heavily restricted.
3.  **Hardened Compute:** The EC2 instance is configured to disable root password logins, enforcing cryptographic SSH keys. (We don't play around with security here! 🛑)

## 🚀 Deployment Instructions (The Runbook)
*(Note: This section acts as the official SOP for the internal team. Documentation is my engineering superpower! *wink wink* 😉)*

### Prerequisites
*   AWS CLI installed and authenticated
*   Terraform installed globally

### Steps to Deploy
1.  Clone this repository to your local machine.
2.  Navigate to the project directory.
3.  Initialize the Terraform working directory:
    ```bash
    terraform init
    ```
4.  Review the infrastructure plan (measure twice, cut once!):
    ```bash
    terraform plan
    ```
5.  Deploy the resources to AWS:
    ```bash
    terraform apply -auto-approve
    ```

---

## 🧪 Phase 3: Server Configuration & Troubleshooting
Once the underlying infrastructure was provisioned via Terraform, I got under the hood to configure the host using EC2 Instance Connect.

### 1. Web Server Installation
I updated the local package indexes and installed the Nginx web daemon:
```bash
sudo apt update
sudo apt install nginx -y

I verified the service was actively running and listening for traffic using `systemctl status nginx`.

### 2. Triage & Connectivity Resolution
This is where the fun problem-solving comes in! 😅

**Issue:** Initial attempts to navigate to the server's public IP address via a web browser resulted in a connection timeout (`ERR_CONNECTION_TIMED_OUT`).

**Root Cause Analysis:**
1. **Host Check:** Verified `systemctl status nginx` on the server; the service was actively listening and healthy.
2. **Firewall Verification:** Inspected AWS Security Group ingress rules; inbound traffic on port 80 (HTTP) was properly allowed.
3. **Resolution:** Modern web browsers automatically attempt to upgrade standard web requests to `https://` (port 443) by default. Because I intentionally omitted port 443 from the security group rules to enforce unencrypted testing, the browser's HTTPS handshake packets were dropped by the AWS hypervisor firewall.

Explicitly prefixing the URL with `http://` forced the client browser to connect over open port 80, successfully reaching Nginx and returning an HTTP 200 payload. We successfully bypassed the blocker and owned the outcome! 🚀

---

## 📈 Monitoring & Alerts
*(Screenshots of CloudWatch dashboard and CPU alerts will go here once completed in Phase 4! Stay tuned 👀)* 