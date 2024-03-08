output "ebs" {
  description = "ID for EBS"
  value       = aws_ebs_volume.data.id
}

output "instance" {
  description = "ID for instance"
  value       = aws_instance.instance[count.index].id
}