resource "aws_s3_bucket" "kinesis_bucket" {
    bucket = var.s3_kinesis_backup_bucket_name
    acl    = "private"
    region = var.selected_region
}

resource "aws_kinesis_firehose_delivery_stream" "VPCFlowLogsToElasticSearch" {
  name        = "VPCFlowLogsToElasticSearch" # This name must match decorator Lambda's environment variable
  destination = "elasticsearch"

  s3_configuration {
    role_arn           = aws_iam_role.firehose_role.arn
    bucket_arn         = aws_s3_bucket.kinesis_bucket.arn
    buffer_size        = 1
    buffer_interval    = 60
    compression_format = "UNCOMPRESSED"    
  }

  elasticsearch_configuration {
    domain_arn = aws_elasticsearch_domain.es_flowlogs.arn
    role_arn   = aws_iam_role.firehose_role.arn
    index_name = "cwl"
    type_name  = "log"
    processing_configuration {
      enabled = "true"
      processors {
        type = "Lambda"
        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = "${data.aws_cloudformation_stack.vpc_flow_log_appender.outputs["LambdaFlowLogDecorator"]}:$LATEST"
        }
      }
    }
    s3_backup_mode = "AllDocuments"
  }
}

resource "aws_iam_role" "firehose_role" {
  name = "firehose_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
          "StringEquals": {
              "sts:ExternalId": "${var.account_id}"
          }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "policy_firehose_permission" {
  name = "policy_firehose_permission"
  role = aws_iam_role.firehose_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeVpcs",
                "ec2:DescribeVpcAttribute",
                "ec2:DescribeSubnets",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeNetworkInterfaces",
                "ec2:CreateNetworkInterface",
                "ec2:CreateNetworkInterfacePermission",
                "ec2:DeleteNetworkInterface"
            ],
            "Resource": "*"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "s3:AbortMultipartUpload",
                "s3:GetBucketLocation",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:ListBucketMultipartUploads",
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::${var.s3_kinesis_backup_bucket_name}",
                "arn:aws:s3:::${var.s3_kinesis_backup_bucket_name}/*"
            ]
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "lambda:InvokeFunction",
                "lambda:GetFunctionConfiguration"
            ],
            "Resource": "arn:aws:lambda:${var.selected_region}:${var.account_id}:function:%FIREHOSE_DEFAULT_FUNCTION%:%FIREHOSE_DEFAULT_VERSION%"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "lambda:InvokeFunction",
                "lambda:GetFunctionConfiguration"
            ],
            "Resource": "${data.aws_cloudformation_stack.vpc_flow_log_appender.outputs["LambdaFlowLogDecorator"]}:*"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "es:DescribeElasticsearchDomain",
                "es:DescribeElasticsearchDomains",
                "es:DescribeElasticsearchDomainConfig",
                "es:ESHttpPost",
                "es:ESHttpPut"
            ],
            "Resource": [
                "arn:aws:es:${var.selected_region}:${var.account_id}:domain/${var.es_domain_name}",
                "arn:aws:es:${var.selected_region}:${var.account_id}:domain/${var.es_domain_name}/*"
            ]
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "es:ESHttpGet"
            ],
            "Resource": [
                "arn:aws:es:${var.selected_region}:${var.account_id}:domain/${var.es_domain_name}/_all/_settings",
                "arn:aws:es:${var.selected_region}:${var.account_id}:domain/${var.es_domain_name}/_cluster/stats",
                "arn:aws:es:${var.selected_region}:${var.account_id}:domain/${var.es_domain_name}/cwl*/_mapping/log",
                "arn:aws:es:${var.selected_region}:${var.account_id}:domain/${var.es_domain_name}/_nodes",
                "arn:aws:es:${var.selected_region}:${var.account_id}:domain/${var.es_domain_name}/_nodes/stats",
                "arn:aws:es:${var.selected_region}:${var.account_id}:domain/${var.es_domain_name}/_nodes/*/stats",
                "arn:aws:es:${var.selected_region}:${var.account_id}:domain/${var.es_domain_name}/_stats",
                "arn:aws:es:${var.selected_region}:${var.account_id}:domain/${var.es_domain_name}/cwl*/_stats"
            ]
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:${var.selected_region}:${var.account_id}:log-group:/aws/kinesisfirehose/:log-stream:*"
            ]
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "kinesis:DescribeStream",
                "kinesis:GetShardIterator",
                "kinesis:GetRecords",
                "kinesis:ListShards"
            ],
            "Resource": "arn:aws:kinesis:${var.selected_region}:${var.account_id}:stream/%FIREHOSE_STREAM_NAME%"
        },
        {
            "Effect": "Allow",
            "Action": [
                "kms:Decrypt"
            ],
            "Resource": [
                "arn:aws:kms:${var.selected_region}:${var.account_id}:key/%SSE_KEY_ID%"
            ],
            "Condition": {
                "StringEquals": {
                    "kms:ViaService": "kinesis.%REGION_NAME%.amazonaws.com"
                },
                "StringLike": {
                    "kms:EncryptionContext:aws:kinesis:arn": "arn:aws:kinesis:%REGION_NAME%:${var.account_id}:stream/%FIREHOSE_STREAM_NAME%"
                }
            }
        }
    ]
}
EOF
}
