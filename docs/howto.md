# Setup Cloud9
	- 作成されるEC2にロールを割り当てる
	- AWS Cloud9 > Prefefent > AWS Settings > Credentials はオフにすることでRoleの権限が利用できる

# Install Tools
	- sudo yum install -y jq
	- wget https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_linux_amd64.zip
	- terraform_0.11.13_linux_amd64.zip
	- chmod +x terraform
	- mkdir ~/bin
	- mv terraform ~/bin/
	- MY_NAME=gino8070

# Clone github repo
	- git clone https://github.com/gino8070/aws-training.git

# Code Commit
	- cd ~/environment/aws-training/terraform/code_commit
	- terraform plan --var "name=$MY_NAME"
	- terraform apply --var "name=$MY_NAME"

# Setting git config
	- git config --global credential.helper '!aws codecommit credential-helper $@'
	- git config --global credential.UseHttpPath true
	- git config --global user.email ""
	- git config --global user.name "${MY_NAME}"

# Clone code commit repo
	- cd ~/environment
	- MY_REPO=$(aws codecommit get-repository --repository-name ${MY_NAME} | jq -r .repositoryMetadata.cloneUrlHttp)
	- git clone $MY_REPO

# First commit
	- cd $MY_NAME
	- cp ../aws-training/app/* .
	- cp ../aws-training/.gitignore
  - git add -A
  - git commit -m 'first commit'
  - git push origin master
	
# Run sample app
	- docker build -t sample_app:v1 .
	- docker run --rm -p 8080:8080 sample_app:v1
	- curl localhost:8080

# Terraform ECR
	- cd ~/environment/aws-training/terraform/ecr
	- terraform init
	- terraform plan --var "name=$MY_NAME"
	- terraform apply --var "name=$MY_NAME"

# Build Docker Pipeline
	- cd ~/environment/aws-training/terraform/build_docker_pipeline
	- terraform init
	- terraform plan --var "name=$MY_NAME" --var "repoName=$MY_NAME" --var "branchName=master"
	- terraform apply --var "name=$MY_NAME" --var "repoName=$MY_NAME" --var "branchName=master"
