# AWS SSM Bastion Module

[![Main Checks][badge-checks]][code-checks] [![GitHub Release][badge-release]][latest-release]

This module launches an EC2 instance that acts as a bastion host for Systems
Manager (SSM) Session Manager. This allows users to connect to the instance as
an entry point to the VPC without needing to manage SSH keys or open the
instance to the internet.

## Usage

Before you can create a bastion, you will need an EC2 key pair to connect with.
See the [key_pair_name] section for instructions on creating and defining a key
pair.

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

To connect to the bastion host, you can connect directly using the Systems
Manager cli, or through SSH. For either method, you will need to have the latest
version of the AWS CLI, and your credentials configured for the appropriate
account.

> [!TIP]
> You can install the required tools on macOS using Homebrew:
>
> ```shell
> brew install awscli session-manager-plugin
> ```

### Connecting with CLI

You can connect to the instance using the AWS CLI and the Session Manager
plugin:

```bash
aws ssm start-session \
    --target <INSTANCE ID>
```

There are a number of additional options available for more complex use cases.
See the [start-session] and [starting a session][start-a-session] documentation
for more information.

This is the preferred method of connecting as it does not require distributing
the private key, and can be audited and controlled through IAM policies.

### Connecting with SSH

You can connect using traditional SSH. This is helpful if you have existing
tooling built around SSH.

Before you can begin, you will need to write the private key to a local file. We
recommend giving it an easy to identify name and storing it in `$HOME/.ssh`. For
example, `$HOME/.ssh/my-project-development-bastion.pem`. Restrict the file's
permissions with `chmod 600 <FILE NAME>`.

Additionally, you will need to create an SSH configuration to proxy the request
to the AWS CLI. Add the following to `$HOME/.ssh/config`:

```ssh
# SSH over Session Manager
Host i-* mi-*
    ProxyCommand sh -c "aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'"
    User ec2-user
```

You can now connect using SSH:

```bash
ssh -i <KEY FILE> <INSTANCE ID>
```

For example:

```bash
ssh -i $HOME/.ssh/my-project-development-bastion.pem i-0a1b2c3d4e5f6g7h8
```

To enable port forwarding, you can add the `-L` flag to the SSH command. For
example, the following command forwards localhost port 9999 to `google.com` port
443:

```bash
ssh -i $HOME/.ssh/my-project-development-bastion.pem -L 9999:google.com:443 i-0a1b2c3d4e5f6g7h8
```

## Inputs

| Name                    | Description                                                                                              | Type     | Default      | Required |
|-------------------------|----------------------------------------------------------------------------------------------------------|----------|--------------|----------|
| private_subnet_ids      | The IDs of the private subnets in which the bastion host should be deployed.                             | `string` | n/a          | yes      |
| project                 | Name of the project.                                                                                     | `string` | n/a          | yes      |
| vpc_id                  | The ID of the VPC in which the bastion host should be deployed.                                          | `string` | n/a          | yes      |
| environment             | Environment for the project.                                                                             | `string` | `"dev"`      | no       |
| instance_type           | The instance type to use for the bastion host.                                                           | `string` | `"t2.micro"` | no       |
| [key_pair_name]         | Name of the EC2 keypair to associate with the instance. Defaults to `${project}-${environment}-bastion`. | `string` | `""`         | no       |
| kms_key_recovery_period | Recovery period for deleted KMS keys in days. Must be between 7 and 30.                                  | `number` | `30`         | no       |
| tags                    | Optional tags to be applied to all resources.                                                            | `list`   | `[]`         | no       |

### key_pair_name

In order to access the bastion host via SSH, you must have an EC2 key pair.
While we _could_ generate a key pair for you, the private key would be stored in
the state file in plain text. Instead, you should create a key pair manually.

You can create a new key pair using the AWS CLI:

```bash
aws ec2 create-key-pair \
  --key-name <KEY NAME> \
  --key-type ed25519 \
  --key-format pem \
  --tag-specifications 'ResourceType=key-pair,Tags=[{Key=project,Value=<PROJECT>},{Key=environment,Value=<ENVIRONMENT>}]' \
  --query KeyMaterial \
  --output text > <KEY NAME>.pem
```

> [!TIP]
> If you choose a key name that matches the default pattern
> (`${project}-${environment}-bastion`), you can omit the `key_pair_name` input.

For example:

```bash
aws ec2 create-key-pair \
  --key-name my-project-development-bastion \
  --key-type ed25519 \
  --key-format pem \
  --tag-specifications 'ResourceType=key-pair,Tags=[{Key=project,Value=my-project},{Key=environment,Value=development}]' \
  --query KeyMaterial \
  --output text > my-project-development-bastion.pem
```

Store the private key in a secure location and share it with the appropriate
users. If you chose a different key name, you must provide it as the value to
`key_pair_name`.

## Outputs

| Name        | Description                 | Type     |
|-------------|-----------------------------|----------|
| instance_id | ID of the bastion instance. | `string` |

## Contributing

Follow the [contributing guidelines][contributing] to contribute to this module.

[badge-checks]: https://github.com/codeforamerica/tofu-modules-aws-ssm-bastion/actions/workflows/main.yaml/badge.svg
[badge-release]: https://img.shields.io/github/v/release/codeforamerica/tofu-modules-aws-ssm-bastion?logo=github&label=Latest%20Release
[code-checks]: https://github.com/codeforamerica/tofu-modules-aws-ssm-bastion/actions/workflows/main.yaml
[contributing]: CONTRIBUTING.md
[key_pair_name]: #key_pair_name
[latest-release]: https://github.com/codeforamerica/tofu-modules-aws-ssm-bastion/releases/latest
[start-a-session]: https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-sessions-start.html
[start-session]: https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ssm/start-session.html
[tofu-modules]: https://github.com/codeforamerica/tofu-modules
