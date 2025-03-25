# AWS SSM Bastion Module

[![Main Checks][badge-checks]][code-checks] [![GitHub Release][badge-release]][latest-release]

This module launches an EC2 instance that acts as a bastion host for Systems
Manager (SSM) Session Manager. This allows users to connect to the instance as
an entry point to the VPC without needing to manage SSH keys or open the
instance to the internet.

## Usage

[//]: # (TODO: Add instructions to create key pair)

Add this module to your `main.tf` (or appropriate) file and configure the inputs
to match your desired configuration. For example:

```hcl
module "bastion" {
  source = "github.com/codeforamerica/tofu-modules-aws-ssm-bastion?ref=1.0.0"

  project            = "my-project"
  environment        = "development"
  key_pair_name      = "my-project-development-bastion"
  private_subnet_ids = module.vpc.private_subnets
  vpc_id             = module.vpc.vpc_id
}
```

Make sure you re-run `tofu init` after adding the module to your configuration.

```bash
tofu init
tofu plan
```

To update the source for this module, pass `-upgrade` to `tofu init`:

```bash
tofu init -upgrade
```

## Connecting

[//]: # (TODO: Add instructions for connecting and port forwarding)

## Inputs

| Name                    | Description                                                                                        | Type     | Default      | Required |
|-------------------------|----------------------------------------------------------------------------------------------------|----------|--------------|----------|
| private_subnet_ids      | The IDs of the private subnets in which the bastion host should be deployed.                       | `string` | n/a          | yes      |
| project                 | Name of the project.                                                                               | `string` | n/a          | yes      |
| vpc_id                  | The ID of the VPC in which the bastion host should be deployed.                                    | `string` | n/a          | yes      |
| environment             | Environment for the project.                                                                       | `string` | `"dev"`      | no       |
| instance_type           | The instance type to use for the bastion host.                                                     | `string` | `"t2.micro"` | no       |
| key_pair_name           | Name of the EC2 keypair to associate with the instance. Defaults to "project-environment-bastion". | `string` | `""`         | no       |
| kms_key_recovery_period | Recovery period for deleted KMS keys in days. Must be between 7 and 30.                            | `number` | `30`         | no       |
| tags                    | Optional tags to be applied to all resources.                                                      | `list`   | `[]`         | no       |

## Outputs

[//]: # (TODO: Replace the following with your own outputs)

| Name        | Description                 | Type     |
|-------------|-----------------------------|----------|
| instance_id | ID of the bastion instance. | `string` |


## Contributing

Follow the [contributing guidelines][contributing] to contribute to this module.

[badge-checks]: https://github.com/codeforamerica/tofu-modules-template/actions/workflows/main.yaml/badge.svg
[badge-release]: https://img.shields.io/github/v/release/codeforamerica/tofu-modules-template?logo=github&label=Latest%20Release
[code-checks]: https://github.com/codeforamerica/tofu-modules-template/actions/workflows/main.yaml
[contributing]: CONTRIBUTING.md
[latest-release]: https://github.com/codeforamerica/tofu-modules-template/releases/latest
[tofu-modules]: https://github.com/codeforamerica/tofu-modules
