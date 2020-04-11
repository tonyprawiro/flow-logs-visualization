# flow-logs-visualization

Terraform code for the following blog post: https://aws.amazon.com/blogs/security/how-to-visualize-and-refine-your-networks-security-by-adding-security-group-ids-to-your-vpc-flow-logs/

# Why

Some feedback, second-hand, and first-hand experience shows that deploying the said project by following the provided instruction is difficult and involves a lot of troubleshooting with varying degree of success. I hope by sharing this script it will help people to implement the solution more consistently successful.

# How it Works

This Terraform stack assumes and needs the following:

- Lambda function has already been deployed prior to running this script. Follow the instruction as specified in [aws-vpc-flow-log-appender GitHub project](https://github.com/aws-samples/aws-vpc-flow-log-appender).

- An existing VPC with at least one public subnet.

- You have an IP range that you want to whitelist. This can be your home or office IP address. This IP range will be able to access the webserver's public port 80 as well as Kibana dashboard endpoint. 

Once the above pre-requisites are completed, create a " terraform.tfvars`" file and assign the appropriate values. Refer to the comments in "`variables.tf`" and "`terraform.tfvars.example`" files for a guide and example of how to correctly write this configuration.

Subsequently, Terraform scripts can be run:

```
PS D:\Project\flow-logs-visualization> terraform init

PS D:\Project\flow-logs-visualization> terraform plan

PS D:\Project\flow-logs-visualization> terraform apply
```

The Terraform stack will use the existing VPC information to create a new VPC Flow Log, and creates an EC2 instance which automatically installs an Apache webserver and simple address book application (taken from AWS Immersion Day EC2 hands-on lab). The Terraform stack will also refer to the Cloudformation stack created by "aws-vpc-flow-log-appender" SAM application to get Lambda functions' ARNs.

The Terraform stack produces two outputs:

- IP address of the web server

- Kibana dashboard hostname

A Powershell script (`loopwebrequest.ps1`) is provided to be run manually after deployment of the Terraform stack is completed. The script will invoke web request continuously to the EC2 webserver's public IP, in order to generate some traffic and VPC Flow Log.

```
PS D:\Project\flow-logs-visualization> .\loopwebrequest.ps1 12.23.34.45
...
RawContent        : HTTP/1.1 200 OK
                    Content-Length: 737
                    Content-Type: text/html; charset=UTF-8
...
```

About 30 minutes after the Terraform stack is deployed, you can visit the Kibana dashboard to complete the index pattern setup and import the "SGDashboard" saved objects (blog post "Step 6: Using the SGDashboard to analyze VPC network traffic").

