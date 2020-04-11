resource "aws_flow_log" "flowlog" {
  iam_role_arn    = aws_iam_role.role_flowlogs.arn
  log_destination = aws_cloudwatch_log_group.loggroup_flowlogs.arn
  traffic_type    = "ALL"
  vpc_id          = data.aws_vpc.selectedvpc.id
}

resource "aws_cloudwatch_log_group" "loggroup_flowlogs" {
  name = "VPCFlowLogs"
}

resource "aws_iam_role" "role_flowlogs" {
  name = "role_flowlogs"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "policy_cloudwatch_flowlogs" {
  name = "policy_cloudwatch_flowlogs"
  role = aws_iam_role.role_flowlogs.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_cloudwatch_log_subscription_filter" "subscription_ingestor" {
  name            = "LambdaStream_Ingestor"
  log_group_name  = aws_cloudwatch_log_group.loggroup_flowlogs.name
  filter_pattern  = "[version, account_id, interface_id, srcaddr != \"-\", dstaddr != \"-\", srcport != \"-\", dstport != \"-\", protocol, packets, bytes, start, end, action, log_status]"
  destination_arn = data.aws_cloudformation_stack.vpc_flow_log_appender.outputs["LambdaFlowLogIngestion"]
}

