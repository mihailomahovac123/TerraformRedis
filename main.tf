
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.62.0"
    }
  }


   backend "s3" {

    bucket="tfstatemihailo"
    key="terraform8.tfstate"
    region="eu-central-1"
  
  }
}

provider "aws" {
  region="eu-central-1"
}

resource "aws_security_group" "redis_sg" {
  name = "redis_sg_mihailo"
  description = "Allow EKS and EC2 access to redis."
  vpc_id = "vpc-0337eff4a58985a95"


    ingress {
    from_port   =  6379
    to_port     =  6379
    protocol    = "tcp" 
    security_groups = ["sg-0bec00a0078ad87c7","sg-042b9774cd276534b"]  //moze i import preko data
    }

    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elasticache_subnet_group" "redis_sng" {
  name       = "redissubnetgroupmihailo"
  subnet_ids = ["subnet-0fdd5e035eb23d4d3", "subnet-07bb23a7feed8fbe9"] 
  
}




resource "aws_elasticache_cluster" "example" {

  cluster_id           = "cluster-redis-mihailo"
  engine               = "redis"
  node_type            = "cache.m4.large"
  num_cache_nodes      = 1
  port                 = 6379
  subnet_group_name = aws_elasticache_subnet_group.redis_sng.name //hocu da obezbedim da bude u odr. subnetovima odr. vpc-ja
  security_group_ids = [aws_security_group.redis_sg.id] //da vidimo da li ce da kreira u istom vpc-ju kao i ove sg
}
//apt install redis-tools on a client
// redis-cli -h cluster-redis-mihailo.k9o4hw.0001.euc1.cache.amazonaws.com -p 6379 // from ec2
