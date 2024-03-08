variable "aws_region" {
  default = "us-east-1"
}

variable "consul_address" {
  type        = string
  description = "Address of Consul server"
  default     = "consul.totaratalent.com"
}

variable "consul_port" {
  type        = number
  description = "Port Consul server is listening on"
  default     = "443"
}

variable "consul_datacenter" {
  type        = string
  description = "Name of the Consul datacenter"
  default     = "us-east-1a"
}

variable "customer_name" {}

variable "customer_pass" {}

variable "customer_doma" {}

variable "db_hostname" {
  default = "mysql57test.cjn38es2ruxd.us-west-2.rds.amazonaws.com"
}