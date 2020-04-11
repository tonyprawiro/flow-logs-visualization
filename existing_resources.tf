data "aws_vpc" "selectedvpc" {
    id = var.selected_vpc_id
}

data "aws_subnet" "selectedsubnet" {
    id = var.selected_subnet_id
}

data "aws_cloudformation_stack" "vpc_flow_log_appender" {
    name = var.vpc_flow_log_appender_cfn_stack
}