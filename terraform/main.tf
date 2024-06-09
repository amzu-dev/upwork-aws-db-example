# Note that These code are for example purpose only, implementation in non-dev environment will be different and will be more secure.
# Configure the AWS provider
provider "aws" {
  region = "your_region"
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "your-vpc"
  }
}

# Create public subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "your_availability_zone_1"
  
  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "your_availability_zone_2"
  
  tags = {
    Name = "public-subnet-2"
  }
}

# Create a security group for the DocumentDB cluster
resource "aws_security_group" "documentdb_sg" {
  name_prefix = "documentdb-sg-"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["your_allowed_cidr_block"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "documentdb-security-group"
  }
}

# Create a DB subnet group
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "your-db-subnet-group"
  subnet_ids = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
  
  tags = {
    Name = "your-db-subnet-group"
  }
}

# Create a DocumentDB cluster
resource "aws_docdb_cluster" "documentdb" {
  cluster_identifier      = "your-documentdb-cluster"
  engine                  = "docdb"
  master_username         = "your_username"
  master_password         = "your_password"
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot     = true
  
  # Enable encryption at rest
  storage_encrypted = true
  
  # Configure network settings
  vpc_security_group_ids = [aws_security_group.documentdb_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
}

# Create a DynamoDB table
resource "aws_dynamodb_table" "dynamodb_table" {
  name           = "your_table_name"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "your_hash_key"
  
  attribute {
    name = "your_hash_key"
    type = "S"
  }
  
  # Enable server-side encryption
  server_side_encryption {
    enabled = true
  }
  
  # Enable point-in-time recovery
  point_in_time_recovery {
    enabled = true
  }
}