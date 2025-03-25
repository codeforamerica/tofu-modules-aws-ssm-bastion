resource "aws_kms_key" "this" {
  description             = "Bastion host encryption key for ${var.project} ${var.environment}"
  deletion_window_in_days = var.kms_key_recovery_period
  enable_key_rotation     = true
  policy = jsonencode(yamldecode(templatefile("${path.module}/templates/key-policy.yaml.tftpl", {
    account_id : data.aws_caller_identity.identity.account_id
    partition : data.aws_partition.current.partition
    region : data.aws_region.current.name
  })))

  tags = merge({ service = "bastion" }, var.tags)
}

resource "aws_kms_alias" "this" {
  name          = "alias/${var.project}/${var.environment}/bastion"
  target_key_id = aws_kms_key.this.id
}
