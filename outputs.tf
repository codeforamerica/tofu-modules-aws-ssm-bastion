output "instance_id" {
  description = "The ID of the bastion host instance."
  value       = aws_instance.this.id
}
