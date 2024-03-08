terraform {
  backend "consul" {
    address = "consul.totaratalent.com"
    path    = "tcc/us-east-1/instance/state/ins"
    scheme  = "https"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "=5.33.0"
    }
    consul = {
      source  = "hashicorp/consul"
      version = "=2.20.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
}

provider "consul" {
  address    = "${var.consul_address}:${var.consul_port}"
  datacenter = var.consul_datacenter
}