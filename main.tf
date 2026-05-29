# ============================================================
#  main.tf
#  The actual AWS infrastructure
#  VPC → Subnet → Security Group → EC2 → Elastic IP
# ============================================================

# ── VPC ──────────────────────────────────────────────────
# A VPC is your own private network inside AWS
# Nothing can communicate in or out without your permission
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name    = "${var.project}-vpc"
    Project = var.project
  }
}

# ── PUBLIC SUBNET ─────────────────────────────────────────
# A subnet is a smaller network inside the VPC
# Public subnet means resources here can reach the internet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project}-public-subnet"
    Project = var.project
  }
}

# ── INTERNET GATEWAY ──────────────────────────────────────
# The door between your VPC and the internet
# Without this, nothing in the VPC can reach the outside
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "${var.project}-igw"
    Project = var.project
  }
}

# ── ROUTE TABLE ───────────────────────────────────────────
# Tells traffic where to go
# 0.0.0.0/0 means "all internet traffic goes through the IGW"
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name    = "${var.project}-rt"
    Project = var.project
  }
}

# ── ROUTE TABLE ASSOCIATION ───────────────────────────────
# Connects the route table to the public subnet
# Without this the subnet doesn't know about the route table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ── SECURITY GROUP ────────────────────────────────────────
# Virtual firewall for the EC2 instance
# Only allows HTTP (80) and SSH (22) inbound
# Allows all outbound traffic
resource "aws_security_group" "web" {
  name        = "${var.project}-web-sg"
  description = "Allow HTTP and SSH"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project}-web-sg"
    Project = var.project
  }
}

# ── EC2 INSTANCE ──────────────────────────────────────────
# The web server
# User data script installs Apache automatically on first boot
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instancs