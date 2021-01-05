provider "aws" {
  region = "eu-west-1"
}

resource "aws_iam_policy" "policy" {
  name        = "paul_lambda_policy"
  path        = "/"
  description = "My test policy"

  policy = <<EOF
{
        "Version": "2012-10-17",
        "Statement": [
          {
            "Effect": "Allow",
            "Action": [
              "logs:CreateLogGroup",
              "logs:CreateLogStream",
              "logs:PutLogEvents"
            ],
            "Resource": "*"
          },
          {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject"
            ],
            "Resource": "arn:aws:s3:::paul-test-bucket-random/*"
        }
        ]
      }
EOF
}

resource "aws_iam_role" "role" {
  name = "paul_role_lambda_test"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_lambda_function" "test_lambda" {
  filename      = "../lambda-s3/lambda_function.zip"
  function_name = "paul-test-lambda"
  role          = aws_iam_role.role.arn
  handler       = "lambda_function.lambda_handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function.zip"))}"
  source_code_hash = filebase64sha256("../lambda-s3/lambda_function.zip")

  runtime = "python3.8"

  environment {
    variables = {
      foo = "bar"
    }
  }
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket = "paul-test-bucket-random"
  acl    = "private"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

module "api-gateway" {
  source = "./modules/api-gateway"

  lambda_arn = aws_lambda_function.test_lambda.invoke_arn
  lambda_function_name = aws_lambda_function.test_lambda.function_name
}
