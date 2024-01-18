# webservice
Deploy an HTML file with security configuration.

## Check
We can check the deployment by typing https://weisongtest.com in the browser. Then we can see the following page:

![image](https://github.com/chfsw/webservice/assets/31757803/8d38143c-f29d-4330-855f-b89e5e503a33)

## Deployment
The web service was deployed in two steps:
1. Providing infrastructure with Terraform. 
2. Deploying HTTPS service with Ansible. 
### Terraform
The following AWS resources are created through Terraform:
+ 1 VPS + 2 subnets + 1 gateway + 1 route table
+ 2 EC2 instances under different subnets. The EC2 instance inbound and outbound traffic are set to 443. Inbound traffic on port 22 is added for Ansible connection.
+ 1 load balancer that assigns requests to the EC2s. The load balancer inbound and outbound traffic are set to 443.
+ 1 certification for TLS
+ route53 zone and record for the pre-existing domain: weisongtest.com

Within the Terraform files directory, run the following commands:
```
terraform init
terraform plan
terraform apply
```

Note: before running these commands, make sure the credentials for AWS operation are ready.

### Ansible
After the resources are created, change the EC2 IP addresses and the path of the private key file (id_rsa in this case) in the inventory.ini file:
```
[webservers]
ec2-instance-A ansible_ssh_host=[EC2 public IP address] ansible_ssh_user=ec2-user ansible_ssh_private_key_file=/the/Path/to/id_rsa
ec2-instance-B ansible_ssh_host=[EC2 public IP address] ansible_ssh_user=ec2-user ansible_ssh_private_key_file=/the/Path/to/id_rsa
```
With the following command, the Httpd service is installed and the HTML and SSL files are uploaded to the EC2 instances:
```
ansible-playbook -i inventory.ini deploy_files.yaml -e 'ansible_host_key_checking=False'
```
Then, run the following command to change listening ports to 443 and set the SSL virtual host:
```
ansible-playbook -i inventory.ini configure_ssl.yaml
```
