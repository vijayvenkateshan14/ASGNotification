

/*resource "null_resource" "delete_file" {
  provisioner "local-exec" {
    command = "rm -f lambda_function.zip"
  }
}*/


data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda_function.zip"
  ##depends_on = [null_resource.delete_file]
}


resource "aws_iam_role" "asg_desired_count_lambda_exec_role" {
  name = "${var.cust_name}-asg-desired-count-lambda-exec-role-${var.report_regions}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}


resource "aws_iam_role_policy" "lambda_logs_policy" {
  name = "${var.cust_name}-asg-desired-count-lambda-exec-role-${var.report_regions}"
  role = aws_iam_role.asg_desired_count_lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow",
        Action   = "logs:CreateLogGroup",
        Resource = "arn:aws:logs:${var.report_regions}:${var.master_account_number}:*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:${var.report_regions}:${var.master_account_number}:log-group:/aws/lambda/${var.cust_name}-monitor-asg-desired-count-${var.report_regions}:*"
      },
      {
        Effect   = "Allow",
        Action   = "sns:Publish",
        Resource = "${var.sns_topic_arn}"
      },
      {
        Effect   = "Allow",
        Action   = "autoscaling:DescribeAutoScalingGroups",
        Resource = "*"
        
      },
    ]
  })
}


resource "aws_lambda_function" "monitor_asg_desired_count" {
  function_name = "${var.cust_name}-monitor-asg-desired-count-${var.report_regions}"
  role          = aws_iam_role.asg_desired_count_lambda_exec_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  timeout       = 900
  memory_size   = 512
  environment {
    variables = {
      sns_topic_arn  = var.sns_topic_arn,
      TZ = "America/New_York"
    }
  }
  source_code_hash  = filebase64sha256(data.archive_file.lambda_zip.output_path)
  filename = data.archive_file.lambda_zip.output_path
  depends_on = [ data.archive_file.lambda_zip ]
}

/*
output "archive_checksum" {
  value = data.archive_file.lambda_zip.output_base64sha256
}*/


/*resource "aws_cloudwatch_event_rule" "monitor_asg_schedule" {
  name                = "${var.cust_name}-monitor-asg-schedule-${var.report_regions}"
  description         = "Scheduled rule check for Desired count on ASG"
  schedule_expression = "cron(*//*5 14-2 * * ? *)"
}

resource "aws_cloudwatch_event_target" "target_monitor_asg" {
  rule      = aws_cloudwatch_event_rule.monitor_asg_schedule.name
  target_id = aws_lambda_function.monitor_asg_desired_count.function_name
  arn       = aws_lambda_function.monitor_asg_desired_count.arn
}

resource "aws_lambda_permission" "allow_eventbridge_to_invoke" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.monitor_asg_desired_count.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.monitor_asg_schedule.arn
}
*/