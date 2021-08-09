terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.48.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
  }

  required_version = "~> 1.0"
}

provider "aws" {
  region = var.aws_region
  profile = var.aws_profile
}

resource "random_pet" "lambda_bucket_name" {
  prefix = "potato"
  length = 4
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = random_pet.lambda_bucket_name.id
  acl           = "private"
  force_destroy = true
}

// Archive py file and save it in s3
data "archive_file" "lambda_api" {
  type = "zip"
  source_dir  = "${path.module}/src/api"
  output_path = "${path.module}/dev/null/api.zip"
}

resource "aws_s3_bucket_object" "lambda_api" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "lambda-api.zip"
  source = data.archive_file.lambda_api.output_path

  etag = filemd5(data.archive_file.lambda_api.output_path)
}
// Create lambda function
// +----------------------------------------------+
resource "aws_lambda_function" "potato_cities" {
  function_name = "PotatoCities"
  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_bucket_object.lambda_api.key
  runtime = "python3.8"
  handler = "potato_cities_get.lambda_handler"
  source_code_hash = data.archive_file.lambda_api.output_base64sha256
  role = aws_iam_role.lambda_exec.arn
  environment {
    variables = {
      OWM_BASE_URL = var.owm_base_url
      OWM_APP_ID = var.owm_appid
    }
  }
}

resource "aws_cloudwatch_log_group" "potato" {
  name = "/aws/lambda/${aws_lambda_function.potato_cities.function_name}"
  retention_in_days = 30
}

resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

output "function_name" {
  description = "Name of the Lambda function."
  value = aws_lambda_function.potato_cities.function_name
}

// Create the RESTful API in API Gateway
// +----------------------------------------------+

resource "aws_apigatewayv2_api" "lambda" {
  name          = "serverless_lambda_gw"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "lambda" {
  api_id = aws_apigatewayv2_api.lambda.id
  name        = "serverless_lambda_stage"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn
    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

resource "aws_apigatewayv2_integration" "potato_cities" {
  api_id = aws_apigatewayv2_api.lambda.id
  integration_uri    = aws_lambda_function.potato_cities.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "potato_cities" {
  api_id = aws_apigatewayv2_api.lambda.id
  route_key = "GET /potato-cities"
  target    = "integrations/${aws_apigatewayv2_integration.potato_cities.id}"
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.lambda.name}"
  retention_in_days = 30
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.potato_cities.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}

output "base_url" {
  description = "Base URL for API Gateway stage."

  value = aws_apigatewayv2_stage.lambda.invoke_url
}
