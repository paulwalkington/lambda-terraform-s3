
resource "aws_iam_role" "paul_first_step_function_lambda_role" {
  name = "paul_step_function_lambda_role"

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

resource "aws_iam_policy" "first_step_function_lambda_policy" {
  name        = "paul_step_function_lambda_policy"
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

resource "aws_iam_role_policy_attachment" "first_step_function_role_policy_attach" {
  role       = aws_iam_role.paul_first_step_function_lambda_role.name
  policy_arn = aws_iam_policy.first_step_function_lambda_policy.arn
}

resource "aws_lambda_function" "first_step_function_lambda" {
  filename      = "../lambda-s3/first_step_function_lambda.zip"
  function_name = "paul-first_step_function-test-lambda"
  role          = aws_iam_role.paul_first_step_function_lambda_role.arn
  handler       = "first_step_function_lambda.lambda_handler"

  source_code_hash = filebase64sha256("../lambda-s3/first_step_function_lambda.zip")

  runtime = "python3.8"

}


resource "aws_iam_role" "state_machine_role" {
  name = "paul_state_machine_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "states.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "state_machine_policy" {
  name        = "paul_state_machine_policy"
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
                "lambda:InvokeFunction"
            ],
            "Resource": "${aws_lambda_function.first_step_function_lambda.arn}"
          }
       ]
    }
EOF
}

resource "aws_iam_role_policy_attachment" "state_machine_role_policy_attach" {
  role       = aws_iam_role.state_machine_role.name
  policy_arn = aws_iam_policy.state_machine_policy.arn
}

resource "aws_sfn_state_machine" "state_machine" {
  name     = "paul-test-state-machine"
  role_arn = aws_iam_role.state_machine_role.arn

  definition = <<EOF
{
  "Comment": "A Hello World example of the Amazon States Language using an AWS Lambda Function",
  "StartAt": "HelloWorld",
  "States": {
    "HelloWorld": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.first_step_function_lambda.arn}",
      "End": true
    }
  }
}
EOF
}