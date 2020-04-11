output "webserverip" {
    value = aws_instance.webserver[*].public_ip
}

output "kibanaendpoint" {
    value = aws_elasticsearch_domain.es_flowlogs.kibana_endpoint
}