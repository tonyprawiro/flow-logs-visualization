resource "aws_instance" "webserver" {
    count = var.webserver_instance_count
    ami = var.instance_ami
    instance_type = var.instance_type
    key_name = var.selected_keypair
    vpc_security_group_ids = [aws_security_group.secgroup_webserver.id]
    subnet_id = var.selected_subnet_id
    associate_public_ip_address = true
    user_data = <<EOF
#include
https://s3.amazonaws.com/immersionday-labs/bootstrap.sh
    EOF
    root_block_device {
        volume_type = "gp2"
        volume_size = "8"
        delete_on_termination = true
    }
    tags = {
        "Name" = "flowlogs_viz_webserver"
        "auto-delete" = "no"
        "auto-stop" = "no"
    }
}

resource "aws_security_group" "secgroup_webserver" {
  name        = "webserver security group"
  description = "webserver security group"
  vpc_id      = var.selected_vpc_id

  ingress {
    description = "HTTP from whitelisted CIDR"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.whitelist_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "webserver security group"
  }
}