# 1. Create the Security Group (The empty firewall shell)
resource "aws_security_group" "web_server_sg" {
  name        = "web-server-sg"
  description = "Allow HTTP and restricted SSH access"

  tags = {
    Name = "web-server-security-group"
  }
}

# 2. Inbound Rule: Allow standard Web Traffic (HTTP) from the internet
resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.web_server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

# 3. Inbound Rule: Allow Administrator SSH Access
resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.web_server_sg.id
  cidr_ipv4         = var.admin_cidr
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# 4. Outbound Rule: Allow the server to send traffic out to the internet
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.web_server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # "-1" means all protocols
}

# EC2 Web Server //////////////////////////////////////////////////////

# 5. Dynamically fetch the latest Ubuntu 22.04 AMI (Amazon Machine Image)
data "aws_ami" "ubuntu" {
  # Tells Terraform to grab the most recent version of this image if multiple updates exist
  most_recent = true

  # Filters the AWS catalog to find the exact naming pattern of the Ubuntu 22.04 image
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  # Filters for Hardware Virtual Machine (HVM) virtualization, the modern AWS standard
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  # Ensures we are downloading the official, secure image directly from Canonical (Ubuntu's creator)
  owners = ["099720109477"]
}

# MANUALLY CONFIGURED EC2 WEB SERVER (without user_data script) //////////////////////////////////////////////////////
# # 6. Create the EC2 Web Server
# resource "aws_instance" "web_server" {
#   # Injects the dynamic ID of the Ubuntu image we found in the data block above
#   ami           = data.aws_ami.ubuntu.id

#   # Sets the hardware size of the server. 
#   # Note: We upgraded this from "t2.micro" to "t3.micro" because AWS is actively phasing out 
#   # the older t2 hardware family. For newly recovered accounts, t3.micro is the modern 
#   # Free Tier standard required to prevent launch blocks.
#   instance_type = "t3.micro" 

#   # Securely attaches the modern standalone security group (firewall) we created earlier
#   vpc_security_group_ids = [aws_security_group.web_server_sg.id]

#   # Assigns a readable name to the server so it is easily identifiable in the AWS Management Console
#   tags = {
#     Name = "portfolio-web-server"
#   }
# }

# AUTOMATED CONFIGURED EC2 WEB SERVER (with user_data script) //////////////////////////////////////////////////////
# 6. Create the EC2 Web Server
resource "aws_instance" "web_server" {
  # Injects the dynamic ID of the Ubuntu image we found in the data block above
  ami = data.aws_ami.ubuntu.id

  # Sets the modern Free Tier standard hardware size
  instance_type = "t3.micro"

  # Attaches the IAM instance profile to allow the EC2 instance to communicate with CloudWatch
  iam_instance_profile = aws_iam_instance_profile.cloudwatch_profile.name

  # Securely attaches the modern standalone security group (firewall)
  vpc_security_group_ids = [aws_security_group.web_server_sg.id]

  # NEW: The user_data script automatically configures the server upon boot.
  # Note: AWS runs user_data scripts as the root user, so 'sudo' is not required.
  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install nginx -y
              systemctl start nginx
              systemctl enable nginx
              EOF

  tags = {
    Name = "portfolio-web-server"
  }

  # Require IMDSv2 (session tokens) to block credential theft via SSRF
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  # Encrypt the root disk at rest
  root_block_device {
    encrypted   = true
    volume_type = "gp3"
  }

}


# 7. IAM Role for CloudWatch
resource "aws_iam_role" "cloudwatch_role" {
  name = "ec2_cloudwatch_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# 8. Attach CloudWatch Policy
resource "aws_iam_role_policy_attachment" "cloudwatch_policy_attach" {
  role       = aws_iam_role.cloudwatch_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# 9. Create Instance Profile
resource "aws_iam_instance_profile" "cloudwatch_profile" {
  name = "ec2_cloudwatch_profile"
  role = aws_iam_role.cloudwatch_role.name
}