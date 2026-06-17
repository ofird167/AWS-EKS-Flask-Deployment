# 1. יצירת ה-VPC
resource "aws_vpc" "AWS-EKS-Flask-Deployment_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "AWS-EKS-Flask-Deployment-vpc"
  }
}

# 2. Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.AWS-EKS-Flask-Deployment_vpc.id

  tags = {
    Name = "AWS-EKS-Flask-Deployment-igw"
  }
}

# 3. סאבנטים ציבוריים (בשני אזורים שונים עבור EKS)
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.AWS-EKS-Flask-Deployment_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name                                       = "AWS-EKS-Flask-Deployment-public-1"
    "kubernetes.io/role/elb"                   = "1"
    "kubernetes.io/cluster/AWS-EKS-Flask-Deployment-cluster" = "shared"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.AWS-EKS-Flask-Deployment_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name                                       = "AWS-EKS-Flask-Deployment-public-2"
    "kubernetes.io/role/elb"                   = "1"
    "kubernetes.io/cluster/AWS-EKS-Flask-Deployment-cluster" = "shared"
  }
}

# 4. סאבנטים פרטיים (בשני אזורים שונים עבור EKS)
resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.AWS-EKS-Flask-Deployment_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name                                       = "AWS-EKS-Flask-Deployment-private-1"
    "kubernetes.io/role/internal-elb"          = "1"
    "kubernetes.io/cluster/AWS-EKS-Flask-Deployment-cluster" = "shared"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.AWS-EKS-Flask-Deployment_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name                                       = "AWS-EKS-Flask-Deployment-private-2"
    "kubernetes.io/role/internal-elb"          = "1"
    "kubernetes.io/cluster/AWS-EKS-Flask-Deployment-cluster" = "shared"
  }
}

# 5. Elastic IP & NAT Gateway עבור הסאבנטים הפרטיים
resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = { Name = "AWS-EKS-Flask-Deployment-nat-eip" }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_1.id
  tags          = { Name = "AWS-EKS-Flask-Deployment-nat-gw" }
}

# 6. טבלאות ניתוב (Route Tables) עם גישה מלאה לאינטרנט החיצון
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.AWS-EKS-Flask-Deployment_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "AWS-EKS-Flask-Deployment-public-rt" }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.AWS-EKS-Flask-Deployment_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = { Name = "AWS-EKS-Flask-Deployment-private-rt" }
}

# 7. קישורי טבלאות ניתוב (Associations)
resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private.id
}