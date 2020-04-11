resource "aws_elasticsearch_domain" "es_flowlogs" {
  domain_name           = var.es_domain_name
  elasticsearch_version = var.es_version
  domain_endpoint_options {
      enforce_https = true
      tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }
  access_policies = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "es:*",
      "Resource": "arn:aws:es:${var.selected_region}:${var.account_id}:domain/${var.es_domain_name}/*",
      "Condition": {
        "IpAddress": {
          "aws:SourceIp": "${var.whitelist_cidr}"
        }
      }
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "es:*",
      "Resource": "arn:aws:es:${var.selected_region}:${var.account_id}:domain/${var.es_domain_name}/*",
      "Condition": {
        "IpAddress": {
          "aws:SourceIp": "${var.kinesis_region_cidr}"
        }
      }
    }
  ]
}
POLICY

  cluster_config {
    instance_type = var.es_instance_type
    instance_count = var.es_instance_count
  }

  ebs_options {
    ebs_enabled = var.es_ebs_enabled
    volume_type = var.es_ebs_volume_type
    volume_size = var.es_ebs_volume_size
  }

}
