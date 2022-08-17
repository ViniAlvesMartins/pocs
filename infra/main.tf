terraform {
  required_version = ">=1.1.4"

  backend "s3" {
    bucket = "state-version"
    key = "terraform-state"
    region = "us-east-1"
  }

  required_providers {
    aws = {
      version = ">= 3.50.0"
      source  = "hashicorp/aws"
    }
  }

}

provider "aws" {
  alias                       = "default"
  profile                     = "default"
  region                      = "us-east-1"
#   skip_credentials_validation = true
#   skip_metadata_api_check     = true
#   skip_requesting_account_id  = true

#   endpoints {
#     apigateway     = "http://localhost:4566"
#     apigatewayv2   = "http://localhost:4566"
#     cloudformation = "http://localhost:4566"
#     cloudwatch     = "http://localhost:4566"
#     dynamodb       = "http://localhost:4566"
#     ec2            = "http://localhost:4566"
#     es             = "http://localhost:4566"
#     elasticache    = "http://localhost:4566"
#     firehose       = "http://localhost:4566"
#     iam            = "http://localhost:4566"
#     kinesis        = "http://localhost:4566"
#     lambda         = "http://localhost:4566"
#     rds            = "http://localhost:4566"
#     redshift       = "http://localhost:4566"
#     route53        = "http://localhost:4566"
#     s3             = "http://s3.localhost.localstack.cloud:4566"
#     secretsmanager = "http://localhost:4566"
#     ses            = "http://localhost:4566"
#     sns            = "http://localhost:4566"
#     sqs            = "http://localhost:4566"
#     ssm            = "http://localhost:4566"
#     stepfunctions  = "http://localhost:4566"
#     sts            = "http://localhost:4566"
#   }
}

data "aws_iam_policy_document" "github_ipd" {
  statement {
    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_ioc.arn]
    }

    condition {
      test = "StringLike"
      variable = "token.actions.githubusercontent.com:aud"
      values = ["sts.amazonaws.com"]
    }

    condition {
      test = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = ["repo:ViniAlvesMartins/pocs:*"]
    }
  }

}

resource "aws_iam_policy" "github_policy" {
  name = "github_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:CreateBucket",
          "s3:PutObject",
          "s3:DeleteBucket",
          "s3:DeleteObject",
          "iam:GetOpenIDConnectProvider",
          "iam:GetPolicy",
          "iam:GetRole",
          "iam:GetPolicyVersion",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies",
          "iam:ListPolicyVersions",
          "s3:*"
        ]

        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })

}

resource "aws_iam_role" "github_iam_role" {
  name = "github"
  assume_role_policy = data.aws_iam_policy_document.github_ipd.json
  managed_policy_arns = [
    aws_iam_policy.github_policy.arn
  ]
}

resource "aws_iam_openid_connect_provider" "github_ioc" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]
}

resource "aws_s3_bucket" "vamnukm1232" {
  bucket = "vamnukm1232"
}
