# terraform-ansible-flask

# Overview
In this project, I implemented a simple Flask app and put it behind HAProxy, which will work as a load balancer.

The basic service of the Flask app is that it only answers requests by replying with the time and hostname of the host that replied.

We expect our service to be a massive hit with our intended customers, so we cannot just run one server. We need multiple servers, let us say 3. To load-balance these servers, we use another server with HAProxy.

The site consists of 5 hosts: HAProxy, web1, web2, web3, Bastion, and an internal site-local network (A network connecting the 5 hosts). The HAProxy acts as an entry point to the service and load-balance between web1, web2, and web3. The last host, Bastion, acts as an SSH entry point to the internal network, i.e., if you connect to Bastion, you can SSH to all the other hosts within the site-local network. Bastion host acts as a secure point for development.

The logical network/service map would be as follows:

(Internet)--->HAProxy(HTTP/80)
             (Internal network using private address range; 10.0.1.0/24)
              +--->web1
              +--->web2
              +--->web3
(Internet)--->Bastion


The infrastructure is provisioned on AWS using Terraform. I used the "terraform-aws-modules / vpc" module to create a custom VPC with public and private subnets within a single az. This aspect is scalable across multiple azs as required for high availability. The HAProxy and the Bastion hosts belong in the public subnet with direct internet access via an Internet Gateway (IGW), whereas the three web servers belong in the private subnet for strong security. They can access the internet via a NAT Gateway placed in the public subnet.


For configuration management, we use Ansible playbook that deploys the HAProxy and Flask app on appropriate existing hosts. Once the hosts are in place, the playbook is run. The playbook is assumed to run -outside- the site, but -via- the Bastion host. Hence, you need to have an SSH config file that allows your host to use the Bastion host as a jump host, using an SSH key. Furthermore, the Bastion host also needs to have SSH access to all the site-local hosts, using SSH keys, to avoid typing passwords all the time.


Another important aspect is the HAProxy performance UI, which will be available to the administrator through a password on port 8011. The HAProxy stats page is available to the administrator who is not a localhost. If the password is changed, access will be restricted. The route is /stats and the refresh rate is 1 second. Replace the default password in the haproxy configuration file with a strong password.


# Prerequisites/Requirements

1. AWS CLIv2 (Source: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
2. Terraform (Source: https://developer.hashicorp.com/terraform/install)
3. Ansible   (Source: https://docs.ansible.com/projects/ansible/latest/installation_guide/index.html)
4. jq        (Source: https://jqlang.org/download/) # For processing terraform output in json

Most importantly, you need an AWS account and an IAM identity (user or role) with appropriate permissions. Terraform uses the credentials of this identity to authenticate with AWS and provision resources.


# Steps

1. Login to your AWS account. Go to IAM service --> Users --> Create user

   Give a User name (e.g. Terraform-Test). In the next step set permissions by selecting 'Attach policies directly'. In the permission policies below, check 'AdministratorAccess'. In the next step review and then click Create user.

   Next, we need to create Access keys. To do this, click on the newly created user --> go to 'Security credentials' tab and click Create access key. Select the use case as Command Line Interface (CLI) and check the Confirmation box and click Next. Set a description tag in the next step to simplify identification. In the next step, you can view/download your access keys. Download the .csv file and store it securely.

2. Open a new terminal and type 'aws configure'. Make sure you have AWS CLIv2 installed before running this command. Enter
   the AWS Access Key ID, AWS Secret Access Key, Default region name (e.g. us-east-1), and the Default output format (e.g. json). This will make sure that Terraform can access your AWS account to provision required resources.

3. Clone the repository. Make sure you have Terraform, Ansible, and jq installed as mentioned in the requirements above.

4. Run the command 'ssh-keygen -t rsa' to generate public-private SSH keypair. Do not input any name and do not enter
   any passphrase. The keys will be saved in the default ~/.ssh directory.

5. Make vars and setup scripts executable. To do this, run 'chmod +x vars.sh setup.sh'.

6. Run 'terraform init' -->  Initializes provider plugins, modules (if any), and creates a lock file .terraform.lock.hcl
   to record the provider selections it made.

   Run 'terraform fmt'  --> Formats all your Terraform code files. (optional, but recommended)

   Run 'terraform validate' --> Checks whether your configuration is syntactically valid and internally consistent
   before attempting to create an execution plan.

   Run './vars.sh' to execute the vars script. The script will prompt you to enter the AWS Region, AWS Availability Zone, EC2 Instance type, and the web count i.e., the number of web servers that should be provisioned. The script then creates a file terraform.tfvars with all the variables you have inputted.

   Run 'terraform plan' --> Generates an execution plan showing exactly what actions Terraform will take to achieve the desired state specified in your configuration files.

   Run 'terraform apply' --> This will apply the configuration. It will prompt you to enter a yes/no, type yes because
   why not? You should see Apply complete! if everything goes well. Also, the outputs will be printed to stdout.

   Run './setup.sh' to execute the setup script. This script will read Terraform outputs and then generate an external
   SSH config file for use by Ansbile.

7. The next step is to run the Ansible playbook (site.yaml). Use the following command:
   ansible-playbook -i hosts site.yaml
   
   The playbook should run without any errors.


You can now access your app by visiting http://<haproxy_public_ip>:80 on your browser.

To access the HAProxy stats page visit http://<haproxy_public_ip>:8011/stats
Pass in the username and password you have set in the haproxy configuration file to access HAProxy load balancer statistics.
