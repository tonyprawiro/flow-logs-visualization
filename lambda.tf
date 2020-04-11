# Decorator and Ingestor function should be provisioned from the Github reporitory using SAM
# https://github.com/aws-samples/aws-vpc-flow-log-appender

# This file contains the manifest of Lambda permission to allow CWL loggroup to invoke this function

# Allow only CW Logs from the FlowLogs log group to execute ingestor function

resource "aws_lambda_permission" "lambda_ingestor_permission" {
  statement_id = "InvokePermissionsForCWL"
  # Allow
  principal = "logs.${var.selected_region}.amazonaws.com"
  action = "lambda:InvokeFunction"
  function_name = data.aws_cloudformation_stack.vpc_flow_log_appender.outputs["LambdaFlowLogIngestion"]
  source_account = var.account_id
  source_arn = aws_cloudwatch_log_group.loggroup_flowlogs.arn
}
