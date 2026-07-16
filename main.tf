# 1. Security Group (Firewall) for the Web Server

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