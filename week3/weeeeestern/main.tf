# provider + 기본 세팅
provider "aws" {
  region  = "ap-northeast-2"
  profile = "default"   # aws configure에서 쓴 프로파일
}

# VPC 생성
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "tf-main-vpc"
  }
}

# Public Subnet (10.0.1.0/24)
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "tf-public-a"
  }
}

# Private Subnet (10.0.11.0/24)
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "tf-private-a"
  }
}

#resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "tf-igw"
  }
}

# NAT용 Elastic IP
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "tf-nat-eip"
  }
}

# NAT Gateway (Public Subnet 안에 있어야 함)
resource "aws_nat_gateway" "nat" {
  subnet_id     = aws_subnet.public_a.id
  allocation_id = aws_eip.nat.id

  tags = {
    Name = "tf-nat-gw"
  }

  depends_on = [aws_internet_gateway.igw] # IGW 먼저 붙이도록
}

# Public Route Table: 인터넷(0.0.0.0/0)으로 가는 길을 IGW로 안내
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "tf-public-rt"
  }
}

# Public Route Table 연결 (Association)
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

# Private Route Table: 인터넷(0.0.0.0/0)으로 가는 길을 NAT GW로 안내
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "tf-private-rt"
  }
}

# Private Route Table 연결 (Association)
resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

