# 1. Security Group (Firewall) for the Web Server

resource "aws_security_group" "web_server_sg" {
  name        = "web-server-sg"
  description = "Allow HTTP and restricted SSH access"

  # Ingress (Inbound) Rule: Allow standard Web Traffic (HTTP) from anyone on the internet
  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  # Ingress (Inbound) Rule: Allow Administrator SSH Access
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # IMPORTANT: We are temporarily leaving this open to the world for testing. 
    # Later, we will lock this down to ONLY your specific home IP address!
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress (Outbound) Rule: Allow the server to send traffic out to the internet
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # "-1" means all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-server-security-group"
  }
}