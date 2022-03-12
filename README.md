# Retag ECR for GitHub Actions

Retag an image in Amazon ECR.

## Description

You can retag without pulling or pushing the image with Docker.
For larger images, this process saves a considerable amount of network bandwidth and time required to retag an image.
This action use only AWS CLI, and not use Docker.

## Usage

### Basic

```yaml
- name: Retag an image in Amazon ECR
  id: retag-ecr
  uses: tmknom/retag-ecr-action@v1
  with:
    repository-name: example
    source-tag: latest
    destination-tag: release
```

### Specify full version

```yaml
- name: Retag an image in Amazon ECR
  id: retag-ecr
  uses: tmknom/retag-ecr-action@v1.0.4
  with:
    repository-name: example
    source-tag: latest
    destination-tag: release
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
  uses: tmknom/retag-ecr-action@v1
  with:
    repository-name: example
    source-tag: latest
    destination-tag: release
```

We recommend [Using OpenID Connect within your workflows to authenticate with AWS](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services).

## Inputs

| Name            | Description                             | Default | Required |
| --------------- | --------------------------------------- | ------- | :------: |
| repository-name | The name to use for the ECR Repository. | n/a     |   yes    |
| source-tag      | The source tag.                         | n/a     |   yes    |
| destination-tag | The destination tag.                    | n/a     |   yes    |

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

## Developer Guide

### Requirements

- [GNU Make](https://www.gnu.org/software/make/)
- [GitHub CLI](https://cli.github.com/)

### Update documents

Update usage automatically in [README.md](/README.md).

```shell
make docs
```

### Prepare Release

Bump up to new release version.

```shell
make bump
```

This command perform the following process:

1. Update [VERSION](/VERSION)
2. Update [README.md](/README.md)
3. Commit and push
4. Create a pull request and open the web browser

### Release

#### 1. Create a new GitHub Release

```shell
make release
```

This command perform the following process:

1. Push tag
2. Create a new GitHub Release as a draft
3. Open the GitHub Release in the web browser

#### 2. Publish actions in GitHub Marketplace

1. Click the edit icon on the right side of the page
2. Edit the release notes
3. If you're ready to publicize your release, click "Publish release"

## References

- [Retagging an image - Amazon ECR](https://docs.aws.amazon.com/AmazonECR/latest/userguide/image-retag.html)

## License

Apache 2 Licensed. See LICENSE for full details.
