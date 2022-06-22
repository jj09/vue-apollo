provider "aws" {
    region      = "us-east-1"
    access_key  = ""
    secret_key  = ""
}
# TODO: put access/secret to ENV https://stackoverflow.com/questions/36629367/getting-an-environment-variable-in-terraform-configuration

variable "subnet_prefix" {
    description = "cidr block for the subnet"
    #default     = "10.0.1.0/24"
    type        = list
}

# 1. Create a VPC
resource "aws_vpc" "prod-vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "production"
    }
}

# 2. Create Internet Gateway
resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.prod-vpc.id
}

# 3. Create Custom Route Table
resource "aws_route_table" "prod-route-table" {
    vpc_id = aws_vpc.prod-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gw.id
    }

    route {
        ipv6_cidr_block = "::/0"
        gateway_id      = aws_internet_gateway.gw.id
    }

    tags = {
        Name = "Prod"
    }
}

# 4. Create a Subnet
resource "aws_subnet" "subnet-1" {
    vpc_id              = aws_vpc.prod-vpc.id
    cidr_block          = var.subnet_prefix[0].cidr_block #"10.0.1.0/24"
    availability_zone   = "us-east-1a"


    tags = {
        Name = var.subnet_prefix[0].name
    }
}

resource "aws_subnet" "subnet-2" {
    vpc_id              = aws_vpc.prod-vpc.id
    cidr_block          = var.subnet_prefix[1].cidr_block #"10.0.1.0/24"
    availability_zone   = "us-east-1a"


    tags = {
        Name = var.subnet_prefix[1].name
    }
}

# 5. Associate subnet with Route Table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.prod-route-table.id
}

# 6. Create Security Group to allow port 22, 80, 443
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.prod-vpc.id

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = [aws_vpc.prod-vpc.ipv6_cidr_block]
  }
  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = [aws_vpc.prod-vpc.ipv6_cidr_block]
  }
  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = [aws_vpc.prod-vpc.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

# 7. Create a network interface with an ip in the subnet that was created in step 4
resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]
}

# 8. Assign an elastic IP to the network interface created in step 7
resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.gw]
}

output "server_public_ip" {
    value = aws_eip.one.public_ip
}

# 9. Create Ubuntu server and install/enable apache2
resource "aws_instance" "web-server-instance" {
    ami                 = "ami-0022f774911c1d690"
    instance_type       = "t2.micro"
    availability_zone   = "us-east-1a"
    key_name            = "terraform-project"

    network_interface {
        network_interface_id = aws_network_interface.web-server-nic.id
        device_index         = 0
    }

    user_data = <<EOF
                #!/bin/bash
                yum update -y
                echo 'Installing unzip...'
                yum install unzip
                echo 'Installing Node v16...'
                curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash # this does not work
                . ~/.nvm/nvm.sh
                nvm install 16
                node -e "console.log('Running Node.js ' + process.version)"
                echo 'Installing MongoDB...'
                chmod 777 /etc/yum.repos.d/
                echo $'[mongodb-org-5.0]\nname=MongoDB Repository\nbaseurl=https://repo.mongodb.org/yum/amazon/2/mongodb-org/5.0/x86_64/\ngpgcheck=0\nenabled=1' > /etc/yum.repos.d/mongodb-org-5.0.repo
                chmod 755 /etc/yum.repos.d/
                yum install -y mongodb-org
                systemctl start mongod
                systemctl enable mongod
                systemctl status mongod
                echo 'Installing PM2...'
                npm install -g pm2
                pm2 startup systemd
                echo 'Installing nginx...'
                amazon-linux-extras install nginx1 -y
                EOF
    tags = {
        Name = "web-server"
    }
}

output "server_private_ip" {
    value = aws_instance.web-server-instance.private_ip
}

output "server_id" {
    value = aws_instance.web-server-instance.id
}

# commands:
# terraform init
# terraform plan
# terraform apply
# terraform apply --auto-approve
# terraform destroy # clean up all resources created/defined in main.tf
# terraform state list
# terraform state show <RESOURCE_NAME>
# terraform output
# terraform refresh # refresh and print output without apply (that can potentially change network settings)
# terraform apply -target <RESOURCE_NAME>
# terraform destroy -target <RESOURCE_NAME>
# terraform apply -var "subnet_prefix=10.0.100.0/24"    # passing varaible
# terraform plan -var-file <FILE_NAME>.tfvars # needed if variables are in different file than terraform.fsvars

## NOT NEEDED
# install apache on EC2
# yum install -y httpd.x86_64
# systemctl start httpd.service
# systemctl enable httpd.service
# echo "Hello from Terraform deployed website! Last deployment: $(date)" > /var/www/html/index.html

# install nodemon
# echo 'Installing nodemon...'
# npm i -g nodemon

## NEEDED

# etc
# sudo yum install unzip
# unzip <FILE_NAME>

# install node: https://github.com/nvm-sh/nvm
# echo 'Installing Node v16...'
# curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
# . ~/.nvm/nvm.sh
# nvm install 16
# node -e "console.log('Running Node.js ' + process.version)"

# install mongo: https://www.solutionanalysts.com/blog/8-simple-steps-to-install-mongodb-with-authentication-on-ec2-ami-linux/
# echo 'Installing MongoDB...'
# sudo chmod 777 /etc/yum.repos.d/
# sudo echo $'[mongodb-org-5.0]\nname=MongoDB Repository\nbaseurl=https://repo.mongodb.org/yum/amazon/2/mongodb-org/5.0/x86_64/\ngpgcheck=0\nenabled=1' > /etc/yum.repos.d/mongodb-org-5.0.repo
# sudo chmod 755 /etc/yum.repos.d/
# sudo yum install -y mongodb-org
# sudo systemctl start mongod
# sudo systemctl enable mongod
# sudo systemctl status mongod

# install PM2
# echo 'Installing PM2...'
# npm install -g pm2
# pm2 startup systemd

# install nginx
# echo 'Installing nginx...'
# sudo amazon-linux-extras install nginx1 -y

# # scp: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AccessingInstancesLinux.html
# echo 'Copy files...'
# sudo chmod 777 /opt
# sudo chmod 777 /etc/nginx/nginx.conf

# echo 'Copy server files...'
# scp -i /Users/jj09/dev/tf-aws/terraform-project.pem -r /Users/jj09/dev/vue-apollo/apollo-mongo-server.zip ec2-user@44.196.200.145:/opt/apollo-mongo-server.zip
# echo 'Copy client files...'
# scp -i /Users/jj09/dev/tf-aws/terraform-project.pem -r /Users/jj09/dev/vue-apollo/html.zip ec2-user@44.196.200.145:/opt/html.zip
# # copy config file/configure nginx (change server part only): https://jasonwatmore.com/post/2019/12/14/vuejs-nodejs-on-aws-how-to-deploy-a-mevn-stack-app-to-amazon-ec2
# scp -i /Users/jj09/dev/tf-aws/terraform-project.pem -r /Users/jj09/dev/vue-apollo/aws/nginx.conf ec2-user@44.196.200.145:/etc/nginx/nginx.conf

# sudo chmod 755 /etc/nginx/nginx.conf
# sudo chmod 755 /opt

# echo 'Unzip files...'
# cd /opt/
# unzip /opt/apollo-mongo-server.zip
# unzip /opt/html.zip
# mv dist html

# echo 'Start Apollo server...'
# cd apollo-mongo-server
# npm i
# pm2 start src/index.js

# # nginx commands: https://phoenixnap.com/kb/nginx-start-stop-restart
# echo 'Restart nginx...'
# sudo systemctl restart nginx
