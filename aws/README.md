# Terraform infra installation and deployment

## Terraform infra installation

1. Copy access key and secret key to main.tf (TODO: do it with ENV vars)
2. Download terraform-project.pem file to ssh and scp
3. From aws dir run:

```
terraform apply
```

## Infra setup

SSH to EC2:

```
ssh -i terraform-project.pem ec2-user@<PUBLIC_IP>
```

Install unzip:

```
echo 'Installing unzip...'
sudo yum install unzip
```

Install node (https://github.com/nvm-sh/nvm)

```
echo 'Installing Node v16...'
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
. ~/.nvm/nvm.sh
nvm install 16
node -e "console.log('Running Node.js ' + process.version)"
```

Install mongo (https://www.solutionanalysts.com/blog/8-simple-steps-to-install-mongodb-with-authentication-on-ec2-ami-linux/)

```
echo 'Installing MongoDB...'
sudo chmod 777 /etc/yum.repos.d/
sudo echo $'[mongodb-org-5.0]\nname=MongoDB Repository\nbaseurl=https://repo.mongodb.org/yum/amazon/2/mongodb-org/5.0/x86_64/\ngpgcheck=0\nenabled=1' > /etc/yum.repos.d/mongodb-org-5.0.repo
sudo chmod 755 /etc/yum.repos.d/
sudo yum install -y mongodb-org
sudo systemctl start mongod
sudo systemctl enable mongod
sudo systemctl status mongod
```

Install PM2

```
echo 'Installing PM2...'
npm install -g pm2
pm2 startup systemd
```

Install nginx

```
echo 'Installing nginx...'
sudo amazon-linux-extras install nginx1 -y
```

Copy nginx config (https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AccessingInstancesLinux.html):

1. Run on EC2:

```
sudo chmod 777 /etc/nginx/nginx.conf
```

2. Run locally:

```
scp -i /Users/jj09/dev/tf-aws/terraform-project.pem -r /Users/jj09/dev/vue-apollo/aws/nginx.conf ec2-user@44.196.200.145:/etc/nginx/nginx.conf
```

https://jasonwatmore.com/post/2019/12/14/vuejs-nodejs-on-aws-how-to-deploy-a-mevn-stack-app-to-amazon-ec2

3. Run on EC2:

```
sudo chmod 755 /etc/nginx/nginx.conf
```

## Server and Client deployment

Copy files

1. Run on EC2:

```
echo 'Copy files...'
sudo chmod 777 /opt
```

2. Run locally:

```
echo 'Copy server files...'
scp -i /Users/jj09/dev/tf-aws/terraform-project.pem -r /Users/jj09/dev/vue-apollo/apollo-mongo-server.zip ec2-user@44.196.200.145:/opt/apollo-mongo-server.zip
echo 'Copy client files...'
scp -i /Users/jj09/dev/tf-aws/terraform-project.pem -r /Users/jj09/dev/vue-apollo/html.zip ec2-user@44.196.200.145:/opt/html.zip
```

3. Run on EC2:

```
sudo chmod 755 /opt
```

Unzip files

```
echo 'Unzip files...'
cd /opt/
unzip /opt/apollo-mongo-server.zip
unzip /opt/html.zip
mv dist html
```

Start Apollo server

```
echo 'Start Apollo server...'
cd apollo-mongo-server
npm i
pm2 start src/index.js
```

Restart nginx (https://phoenixnap.com/kb/nginx-start-stop-restart)

```
echo 'Restart nginx...'
sudo systemctl restart nginx
```

## References

- Installing node on EC2: https://github.com/nvm-sh/nvm
- Installing Mongo on EC2: https://www.solutionanalysts.com/blog/8-simple-steps-to-install-mongodb-with-authentication-on-ec2-ami-linux/
- Accessing Linux instances on EC2: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AccessingInstancesLinux.html
- Deploying MEVN (Mongo+Express+Vue+Node) on EC2: https://jasonwatmore.com/post/2019/12/14/vuejs-nodejs-on-aws-how-to-deploy-a-mevn-stack-app-to-amazon-ec2
- Nginx commands: https://phoenixnap.com/kb/nginx-start-stop-restart

## TODOs

- figure out how to install node with terraform during infra deployment (it fails)
