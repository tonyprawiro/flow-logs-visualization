# Your 12- digits AWS account number
variable "account_id" { type = string }

# Region code e.g. ap-southeast-1
variable "selected_region" { type = string }

# The VPC ID that you want to analyze
variable "selected_vpc_id" { type = string }

# Where you want the ec2 instance to be hosted
variable "selected_subnet_id" { type = string }

# Cloudformation Stack name after you have deployed the 2 Lambda functions
# Refer to https://github.com/awslabs/aws-vpc-flow-log-appender
variable "vpc_flow_log_appender_cfn_stack" { type = string }

# IP address to be whitelisted for the EC2 webserver
variable "whitelist_cidr" { type = string }

# Elasticsearch variables
variable "es_domain_name" { type = string }
variable "es_version" { type = string }
variable "es_instance_type" { type = string }
variable "es_instance_count" { type = number }
variable "es_ebs_enabled" { type = bool }
variable "es_ebs_volume_type" { type = string }
variable "es_ebs_volume_size" { type = number }

# S3 to be used to keep Kinesis Firehose delivery stream backup (failed docs)
variable "s3_kinesis_backup_bucket_name" { type = string }

# Kinesis
# IP address range of the Kinesis endpoint (Kinesis -> Elasticsearch)
# Refer to https://docs.aws.amazon.com/firehose/latest/dev/controlling-access.html
variable "kinesis_region_cidr" { type = string }

# EC2 instance for traffic generation
variable "webserver_instance_count" { type = number }
variable "instance_ami" { type = string }
variable "instance_type" { type = string }
variable "selected_keypair" { type = string }
