resource "random_string" "vm-name" {
  length  = 2
  upper   = false
  number  = true
  lower   = false
  special = false
}

locals {
  instance_type = jsondecode(data.consul_keys.instance.var.instance)["instance_type"]

  common_tags = merge(jsondecode(data.consul_keys.instance.var.com_tags),
    {
      Environment = terraform.workspace
      probe = "https://${var.customer_doma}"
      handler = var.customer_name
    },
    {
      Name = "ec2-tcc-${terraform.workspace}-${var.customer_name}-${random_string.vm-name.result}"
    },
  )
}

resource "aws_ebs_volume" "data" {
  availability_zone = "us-east-1a"
  type = "gp3"
  iops = "3000"
  throughput = "125"
  size              = 10
  tags = {
    Name = "data_${var.customer_name}"
    Backup = "true"
  }
}

resource "aws_instance" "instance" {
  ami           = data.aws_ami.ami.id
  availability_zone = "us-east-1a"
  instance_type = local.instance_type
  subnet_id = jsondecode(data.consul_keys.instance.var.instance)["subnet_id"]
  associate_public_ip_address = false
  vpc_security_group_ids = [
    jsondecode(data.consul_keys.instance.var.instance)["securitygroup0"],
    jsondecode(data.consul_keys.instance.var.instance)["securitygroup1"]
  ]
  key_name = "devops"
  tags = local.common_tags
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdb"
  volume_id   = aws_ebs_volume.data.id
  instance_id = aws_instance.instance.id
}
