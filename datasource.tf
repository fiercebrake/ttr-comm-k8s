data "aws_ami" "ami" {
  most_recent = true
  filter {
    name   = "image-id"
    values = ["ami-0819ff1ad0ab25a23"]
  }
}


data "consul_keys" "instance" {
  key {
    name = "instance"
    path = terraform.workspace == "default" ? "tcc/us-east-1/instance/config/ins_nfo" : "tcc/us-east-1/instance/config/${terraform.workspace}_ins_nfo"
  }

  key {
    name = "com_tags"
    path = "tcc/us-east-1/instance/config/com_tags"
  }
}