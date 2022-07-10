terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">3.0.0"
    }
  }
}

# one more line
provider "aws" {
  region = var.region
}

data "aws_iam_user" "input_user" {
  count = "${var.user == "none" ? 0 : 1}"
  user_name = var.user
}

resource "aws_s3_bucket" "bucket" {
  bucket = var.name
  aws_s3_bucket_acl    = "public-read"
  force_destroy = true

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
    AMAZING_TAG = "AMAZING_VALUE"
  }
}

# CREATE USER and POLICY


resource "aws_iam_user_policy_attachment" "attachment" {  
    count = "${var.user == "none" ? 0 : 1}"
    user       = data.aws_iam_user.input_user[0].user_name 
    policy_arn = aws_iam_policy.policy[0].arn
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.bucket.arn
}

resource "aws_iam_policy" "policy" {
  name        = "${random_pet.pet_name.id}-policy"
  description = "My test policy"

  policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:ListAllMyBuckets"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.bucket.arn}"
    }
  ]
}
EOT
}
