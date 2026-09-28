# 🚀 Secure AWS Web Infrastructure Automation Project Journal 

## 👋🏾 Hey there! 

### Project Overview

I am **SO FREAKING EXCITED** to share this project! If you know me, you know my absolute favorite place to be is joyfully behind a computer screen, bringing order and reliability to digital chaos ✨.

This project was built to solve a real-world business problem for a fast-growing B2B SaaS startup. They needed a highly secure, reliable, and proactively monitored web server deployed in the cloud. My goal? Architect and deploy a hardened Linux web server in AWS using Infrastructure as Code (IaC), enforce least-privilege access, and write the beautiful, easy-to-read documentation that internal teams actually *want* to use to take over maintenance!

## 🛠️ The Tech Stack
As a fellow DIY-er and recently new infrastructure nerd, I chose these specific tools for their power and cost-effectiveness:
*   ☁️ **Cloud Provider:** Amazon Web Services (AWS)
*   🏗️ **Infrastructure as Code:** Terraform
*   🐧 **OS:** Ubuntu Linux 22.04 LTS
*   🌐 **Web Server:** Nginx (managed via `systemd`)
*   🔒 **Security & Governance:** AWS Security Groups, IAM, SSH Key-Based Authentication[cite: 4, 26]
*   👁️ **Observability:** AWS CloudWatch[cite: 21, 26]

## 🏰 Phase 1: Architecture & Security Implementation
To meet strict security requirements, I built this with a major "Security-First" approach:
1.  **Network Isolation:** Everything lives securely inside a dedicated Virtual Private Cloud (VPC).
2.  **Strict Firewall Rules:** Security Groups are locked down to only allow HTTP traffic from the public web, and SSH access is heavily restricted.
3.  **Hardened Compute:** The EC2 instance is configured to disable root password logins, enforcing cryptographic SSH keys. (We don't play around with security here! 🛑)

## 🧪 Phase 2: Server Configuration & Troubleshooting
Once the underlying infrastructure was provisioned via Terraform, I got under the hood to configure the host using EC2 Instance Connect.

### Web Server Installation
I updated the local package indexes and installed the Nginx web daemon:
```bash
sudo apt update
sudo apt install nginx -y
```
I verified the service was actively running and listening for traffic using `systemctl status nginx`.

<!-- Phase 2: Nginx Service Status -->
<table width="100%">
  <tr>
    <th align="center">📸 Nginx Service Active Status</th>
  </tr>
  <tr>
    <td align="center">
      <img src="/images/02-nginx-service-status.png" alt="Nginx Service Active Status">
    </td>
  </tr>
</table>

<!-- Phase 2: Web Server Response & Security Groups -->
<table width="100%">
  <tr>
    <th align="center">📸 Successful Nginx Web Server Response</th>
  </tr>
  <tr>
    <td align="center">
      <img src="/images/01-nginx-welcome-page.png" alt="Successful Nginx Web Server Response">
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="/images/03-aws-security-group-rules.png" alt="AWS Security Group Rules">
    </td>
  </tr>
</table>

## 🤖 Phase 3: Automated Provisioning (Look Ma, no hands!)
While I loved getting under the hood to manually configure the server via SSH, modern cloud administration is all about automation and repeatable deployments!

To make this infrastructure truly scalable, I upgraded my Terraform blueprint to do the heavy lifting for me. I embedded a bash `user_data` script directly into the EC2 resource block. 

Now, the exact moment the EC2 instance boots up, AWS automatically updates the local package indexes, installs Nginx, and enables the web daemon in the background. It completely eliminates the need for manual SSH configuration and guarantees a perfect, human-error-free deployment every single time. 


<!-- Phase 3: Automated Provisioning -->
<table width="100%">
  <tr>
    <th align="center">📸 Automated Deployment Verification</th>
  </tr>
  <tr>
    <td align="center">
      <img src="/images/04-terraform-apply-success.png" alt="Terraform Automation Code & Success">
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="/images/05-automated-nginx-page.png" alt="Fully Automated Live Server">
    </td>
  </tr>
</table>
---

## 👁️ Phase 4: Observability & Proactive Monitoring
A true cloud engineer knows when a server breaks before the users do! To prove I can maintain and observe a production environment, I implemented AWS CloudWatch.

Because AWS operates on a strict "Security-First" model, an EC2 instance cannot just send data wherever it wants. I used Terraform to architect a secure Identity and Access Management (IAM) Role—essentially a digital VIP badge—and attached the official `CloudWatchAgentServerPolicy`. I then wrapped this in an IAM Instance Profile and handed that lanyard directly to my web server resource.

Finally, I updated my `user_data` script to automatically download, configure, and launch the CloudWatch agent during the server's boot sequence. Now, my infrastructure proactively streams its internal CPU and memory metrics to a centralized dashboard without me ever having to log in manually! 

<!-- Phase 4: Observability & Proactive Monitoring -->
<table width="100%">
  <tr>
    <th align="center">📸 CloudWatch Telemetry Dashboard & Alarms</th>
  </tr>
  <tr>
    <td align="center">
      <img src="/images/06-cloudwatch-dashboard.png" alt="CloudWatch CPU Metrics">
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="/images/07-cloudwatch-alarm.png" alt="CloudWatch SNS Email Alarm Status">
    </td>
  </tr>
</table>

---

<details>
<summary><h2>🚨 Appendix A: Triage & Connectivity Resolution (Click to Expand 🔽)</h2></summary>

> This is where the fun problem-solving comes in! 😅
> 
> **Issue:** Initial attempts to navigate to the server's public IP address via a web browser resulted in a connection timeout (`ERR_CONNECTION_TIMED_OUT`).
> 
> **Root Cause Analysis:**
> 1. **Host Check:** Verified `systemctl status nginx` on the server; the service was actively listening and healthy.
> 2. **Firewall Verification:** Inspected AWS Security Group ingress rules; inbound traffic on port 80 (HTTP) was properly allowed.
> 3. **Resolution:** Modern web browsers automatically attempt to upgrade standard web requests to `https://` (port 443) by default. Because I intentionally omitted port 443 from the security group rules to enforce unencrypted testing, the browser's HTTPS handshake packets were dropped by the AWS hypervisor firewall.
> 
> Explicitly prefixing the URL with `http://` forced the client browser to connect over open port 80, successfully reaching Nginx and returning an HTTP 200 payload. We successfully bypassed the blocker and owned the outcome! 🚀

<table width="100%">
  <tr>
    <th align="center">📸 Successful Nginx Web Server Response</th>
  </tr>
  <tr>
    <td align="center">
      <img src="/images/01-nginx-welcome-page.png" alt="Successful Nginx Web Server Response">
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="/images/03-aws-security-group-rules.png" alt="AWS Security Group Rules">
    </td>
  </tr>
</table>

</details>

<details>
<summary><h2>📖 Appendix B: Deployment Instructions / Runbook (Click to Expand 🔽)</h2></summary>

> *(Note: This section acts as the official SOP for the internal team. Documentation is my engineering superpower! *wink wink* 😉)*
> 
> ### Prerequisites
> *   AWS CLI installed and authenticated
> *   Terraform installed globally
> 
> ### Steps to Deploy
> 1.  Clone this repository to your local machine.
> 2.  Navigate to the project directory.
> 3.  Initialize the Terraform working directory:
>     ```bash
>     terraform init
>     ```
> 4.  Review the infrastructure plan (measure twice, cut once!):
>     ```bash
>     terraform plan
>     ```
> 5.  Deploy the resources to AWS:
>     ```bash
>     terraform apply -auto-approve
>     ```

</details>