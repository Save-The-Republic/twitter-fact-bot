provider "aws" {
  region = "us-east-1"
  profile = "twitter-bot-test"
}

data "aws_caller_identity" "current" {}

data "archive_file" "python_payload" {
  type        = "zip"
  source_dir  = "${path.module}/twitter-bot/"
  output_path = "${path.module}/files/lambda_payload.zip"
}

data "aws_iam_policy_document" "twitterbot_lambda_policy_doc" {
  statement {
    resources = ["arn:aws:logs:us-east-1:${data.aws_caller_identity.current.account_id}:*"]
    actions   = ["logs:CreateLogGroup"]
  }

  statement {
    resources = ["arn:aws:logs:us-east-1:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/twitter-bot:*"]

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }

  statement {
    resources = [var.kms_key_arn]
    actions = [
      "kms:Decrypt"
    ]
  }
}

data "aws_iam_policy_document" "lambda_assumerole" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "twitterbot_lambda_policy" {
  name        = "tf-twitterbot-${var.env}"
  description = "Terraform Managed. Allows Twitterbot Lambda function to execute and access S3."
  policy      = data.aws_iam_policy_document.twitterbot_lambda_policy_doc.json
}

resource "aws_iam_role" "twitterbot_lambda_role" {
  name               = "tf-twitterbot-${var.env}"
  description        = "Terraform Managed. Allows Twitterbot Lambda function to execute and access S3."
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.lambda_assumerole.json
}

resource "aws_iam_role_policy_attachment" "twitterbot_lambda_roleattach" {
  role       = aws_iam_role.twitterbot_lambda_role.name
  policy_arn = aws_iam_policy.twitterbot_lambda_policy.arn
}

resource "aws_lambda_function" "twitterbot_lambda" {
  filename         = "${path.module}/files/lambda_payload.zip"
  function_name    = "twitter-bot"
  role             = aws_iam_role.twitterbot_lambda_role.arn
  handler          = "twitter_bot.handler"
  source_code_hash = data.archive_file.python_payload.output_base64sha256
  timeout          = 10
  kms_key_arn      = var.kms_key_arn

  runtime = "python3.8"

  environment {
    variables = {
      SLACK_WEBHOOK = var.encrypted_slack_webhook
    }
  }
}

resource "aws_cloudwatch_event_rule" "every_one_minute" {
  name                = "every-one-minute"
  description         = "Fires every one minute"
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "check_twitterbot_sched" {
  rule      = aws_cloudwatch_event_rule.every_one_minute.name
  target_id = "check_twitterbot"
  arn       = aws_lambda_function.twitterbot_lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_twitterbot" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.twitterbot_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_one_minute.arn
}
