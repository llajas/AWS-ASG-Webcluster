Contained in this folder are two major resources:

1. global - This folder contains the necessary Terraform code to create an s3 bucket and DynamoDB table for storing/locking the state file in a secure fashion. More information can be found inside the 'README.MD' file inside the global folder. Do note that this is not necessary, but allows for the state file to be locked for colloboration and encrypted to prevent reading of secrets once implemented into state.

2. web-server - A web app contained within that operates with/under following conditions:
    A private VPC just for the web application.
    Dual public & private subnets. These are spread across separate AWS zones for added resiliency.
    A load balancer with ingress limited to port 80 for web access. 
    *SSH / Port 22 access within the private subnet
    A data source which is set to search for and use the latest AWS AMI to be supplied to the ASG.
    Instances within the ASG are also configured with a secondary volume for storing the log data from the underlying NGINX server.
    The lone output provides the DNS name for the load balancer which can be accessed via web browser - This should display the hostname of the currently running instance along with a friendly hello message.
    The ASG is monitored by a simple AWS CloudWatch alarm which watches the CPU usage of the cluster and will react by increasing available ec2 instances up to 4 if CPU usage spikes above 90% for too long.


Do note the following:

1. As part of management, the web server code assumes that a public key is in place under your AWS account which is added to each instance to allow for SSH acccess/management from the private subnet.*

2. State file will be stored locally by default - To change this, uncomment the final 'terraform' block within the 'main.tf' file and include your s3 bucket as well as DynamoDB table. Both of these can be procured by running the plan within 'Global' to create an s3 bucket and DynamoDB table for storing the remote state securely. 