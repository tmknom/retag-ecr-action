# Retag ECR for GitHub Actions

This action retags an image in Amazon ECR.

## Description

You can retag without pulling or pushing the image with Docker.
For larger images, this process saves a considerable amount of network bandwidth and time required to retag an image.
This action use only AWS CLI, and not use Docker.

## Usage

```yaml
- name: Retag an image in Amazon ECR
  id: retag-ecr
  uses: tmknom/retag-ecr-action@ba4be15a94c10e85c3e56936e69d1d73390d3318
  with:
    repository-name: example
    from-tag: latest
    to-tag: release
```

## Credentials and Region

Use the [aws-actions/configure-aws-credentials](https://github.com/aws-actions/configure-aws-credentials) action to
configure the GitHub Actions environment with environment variables containing AWS credentials and your desired region.

```yaml
- name: Configure AWS Credentials
  uses: aws-actions/configure-aws-credentials@v1
  with:
    aws-region: ap-northeast-1
    role-to-assume: arn:aws:iam::123456789100:role/my-github-actions-role
    role-session-name: ${{ github.event.repository.name }}-${{ github.run_id }}

- name: Retag an image in Amazon ECR
  id: retag-ecr
  uses: tmknom/retag-ecr-action@ba4be15a94c10e85c3e56936e69d1d73390d3318
  with:
    repository-name: example
    from-tag: latest
    to-tag: release
```

We recommend [Using OpenID Connect within your workflows to authenticate with AWS](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services).

## Inputs

| Name            | Description                             | Default | Required |
| --------------- | --------------------------------------- | ------- | :------: |
| repository-name | The name to use for the ECR Repository. | n/a     |   yes    |
| from-tag        | The from image tag.                     | n/a     |   yes    |
| to-tag          | The to image tag.                       | n/a     |   yes    |

## Outputs

N/A

## Environment variables

N/A

## Permissions for the `GITHUB_TOKEN`

There are no required permissions for this action itself.

## Permissions for AWS IAM Policy

This action requires the following minimum set of permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["ecr:ListImages"],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": ["ecr:BatchGetImage", "ecr:PutImage"],
      "Resource": [
        "arn:aws:ecr:<region>:<aws_account_id>:repository/<repository_name>"
      ]
    }
  ]
}
```

## References

- [Retagging an image - Amazon ECR](https://docs.aws.amazon.com/AmazonECR/latest/userguide/image-retag.html)

## License

Apache 2 Licensed. See LICENSE for full details.
