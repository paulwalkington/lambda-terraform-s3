provider "aws" {
  region = "eu-west-1"
}

resource "aws_iam_policy" "gateway_lambda_policy" {
  name        = "paul_gateway_lambda_policy"
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

resource "aws_iam_policy" "sqs_lambda_policy" {
  name        = "paul_sqs_lambda_policy"
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
              "logs:PutLogEvents",
              "sqs:ReceiveMessage",
              "sqs:DeleteMessage",
              "sqs:GetQueueAttributes"
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

resource "aws_iam_role" "gateway_lambda_role" {
  name = "paul_gateway_role_lambda_test"

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

resource "aws_iam_role" "sqs_lambda_role" {
  name = "paul_sqs_role_lambda_test"

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

resource "aws_iam_role_policy_attachment" "gateway_role_policy_attach" {
  role       = aws_iam_role.gateway_lambda_role.name
  policy_arn = aws_iam_policy.gateway_lambda_policy.arn
}

resource "aws_iam_role_policy_attachment" "sqs_role_policy_attach" {
  role       = aws_iam_role.sqs_lambda_role.name
  policy_arn = aws_iam_policy.sqs_lambda_policy.arn
}

resource "aws_lambda_function" "gateway_lambda" {
  filename      = "../lambda-s3/gateway_lambda_function.zip"
  function_name = "paul-gateway-test-lambda"
  role          = aws_iam_role.gateway_lambda_role.arn
  handler       = "gateway_lambda_function.lambda_handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function.zip"))}"
  source_code_hash = filebase64sha256("../lambda-s3/gateway_lambda_function.zip")

  runtime = "python3.8"

  environment {
    variables = {
      foo = "bar"
    }
  }
}

resource "aws_lambda_function" "sqs_lambda" {
  filename      = "../lambda-s3/sqs_lambda_function.zip"
  function_name = "paul-sqs-test-lambda"
  role          = aws_iam_role.sqs_lambda_role.arn
  handler       = "sqs_lambda_function.lambda_handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function.zip"))}"
  source_code_hash = filebase64sha256("../lambda-s3/sqs_lambda_function.zip")

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

  lambda_arn = aws_lambda_function.gateway_lambda.invoke_arn
  lambda_function_name = aws_lambda_function.gateway_lambda.function_name
}

resource "aws_sqs_queue" "sqs_queue_test" {
  name                      = "paul-example-queue"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
}

resource "aws_lambda_event_source_mapping" "source_mapping_example" {
  event_source_arn = aws_sqs_queue.sqs_queue_test.arn
  function_name    = aws_lambda_function.sqs_lambda.arn
}
