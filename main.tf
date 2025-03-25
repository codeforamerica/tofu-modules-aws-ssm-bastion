resource "random_shuffle" "subnet" {
  input        = var.private_subnet_ids
  result_count = 1
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.3"

  name   = "${local.prefix}-bastion"
  vpc_id = var.vpc_id

  # Allow all egress.
  egress_rules = ["all-all"]

  tags = merge({ service = "bastion" }, var.tags)
}

resource "aws_instance" "this" {
  ami           = data.aws_ami.bastion.id
  instance_type = var.instance_type

  vpc_security_group_ids = [module.security_group.security_group_id]

  iam_instance_profile        = "AmazonSSMRoleForInstancesQuickSetup"
  associate_public_ip_address = false
  key_name                    = local.key_pair_name
  subnet_id                   = random_shuffle.subnet.result[0]
  monitoring                  = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted   = true
    volume_size = 10
    kms_key_id  = aws_kms_key.this.arn
  }

  tags = merge({
    Name    = "${local.prefix}-bastion"
    service = "bastion"
  }, var.tags)

  volume_tags = merge({ service = "bastion" }, var.tags)

  lifecycle {
    create_before_destroy = true
  }
}
