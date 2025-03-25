locals {
  prefix        = "${var.project}-${var.environment}"
  key_pair_name = var.key_pair_name != "" ? var.key_pair_name : "${var.project}-${var.environment}-bastion"
}
