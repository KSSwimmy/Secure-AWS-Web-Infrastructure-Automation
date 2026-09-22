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
  cidr_ipv4         = "0.0.0.0/0" # We will lock this down to your IP later!
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

# 6. Create the EC2 Web Server
resource "aws_instance" "web_server" {
  # Injects the dynamic ID of the Ubuntu image we found in the data block above
  ami           = data.aws_ami.ubuntu.id
  
  # Sets the hardware size of the server. 
  # Note: We upgraded this from "t2.micro" to "t3.micro" because AWS is actively phasing out 
  # the older t2 hardware family. For newly recovered accounts, t3.micro is the modern 
  # Free Tier standard required to prevent launch blocks.
  instance_type = "t3.micro" 
  
  # Securely attaches the modern standalone security group (firewall) we created earlier
  vpc_security_group_ids = [aws_security_group.web_server_sg.id]

  # Assigns a readable name to the server so it is easily identifiable in the AWS Management Console
  tags = {
    Name = "portfolio-web-server"
  }
}