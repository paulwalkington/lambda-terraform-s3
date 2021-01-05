variable "lambda_arn" {
  description = "lambda_arn of the lambda the api gateway will talk to"
  type = string
}

variable "lambda_function_name" {
  type = string
}

variable "myregion" {
  type = string
  default = "eu-west-1"
}

variable "accountId" {
  type = string
  default = 455073406672
}