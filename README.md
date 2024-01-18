# webservice
Deploy an HTML file with security configuration.

## Check
We can check the deployment by typing https://weisongtest.com in the browser. Then we can see the following page:

![image](https://github.com/chfsw/webservice/assets/31757803/8d38143c-f29d-4330-855f-b89e5e503a33)

## Deployment
The web service was deployed in two steps:
1. Providing infrastructure with Terraform. 
2. Deploying HTTPS server with Ansible. 
### Terraform
The following AWS resources are created through Terraform:
+ 1 VPS + 2 subnets + 1 gateway + 1 route table
+ 2 EC2 instances under each subnet
+ 1 load balancer that assigns requests to the EC2s
+ 1 certification for TLS
+ route53 zone and record for the pre-existing domain: weisongtest.com

### Ansible
The following files are uploaded to the EC2 instances through Ansible:
+ HTML file
+ crt file and key file for HTTPS configuration

The following configurations are made through Ansible:

+ Change the listen port to 443
+ Configure the SSL virtual host
