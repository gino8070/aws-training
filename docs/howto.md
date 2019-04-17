# Caution

ALBの作成やECSクラスターの作成などは省略しています

# Setup Cloud9
  - Create Environment
    - Name
      - yourname
    - Environment Type
      - Create a new instance for environment(EC2)
    - InstanceType
      - t3.medium
    - Platform
      - Amazon Linux
    - Cost Saving
      - After a day
    - Network setting
      - ...
	- 作成されるEC2にロールを割り当てる
    - EC2 -> aws-cloud9-xxxx
      - IAM Roleの割り当て
  - 作成されたEC2のSG変更
    - EC2 -> aws-cloud9-xxxx
      - SecurityGroup
        - Add Inbound 8080 MyIP
  - Setting Cloud9
	  - AWS Cloud9 > Prefefent > AWS Settings > Credentials はオフにすることでRoleの権限が利用できる

---

以降はCloud9のTerminalでの操作

# Common Setting
	- MY_NAME=gino8070

# Install Tools
	- sudo yum install -y jq
	- wget https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_linux_amd64.zip
	- unzip terraform_0.11.13_linux_amd64.zip
	- chmod +x terraform
	- mkdir ~/bin
	- mv terraform ~/bin/

# Clone github repo
	- git clone https://github.com/gino8070/aws-training.git

# Code Commit
	- cd ~/environment/aws-training/terraform/code_commit
  - terraform init
	- terraform plan --var "name=$MY_NAME"
	- terraform apply --var "name=$MY_NAME"

# Setting git config
	- git config --global credential.helper '!aws codecommit credential-helper $@'
	- git config --global credential.UseHttpPath true
	- git config --global user.email ""
	- git config --global user.name "${MY_NAME}"

# Clone code commit repo
	- cd ~/environment
	- MY_REPO=$(aws codecommit get-repository --repository-name ${MY_NAME} --region ap-northeast-1 | jq -r .repositoryMetadata.cloneUrlHttp)
	- git clone $MY_REPO

# First commit
	- cd $MY_NAME
	- cp ../aws-training/app/* .
	- cp ../aws-training/.gitignore .
  - git add -A
  - git commit -m 'first commit'
  - git push origin master
	
# Run sample app
	- docker build -t sample_app:v1 .
	- docker run --rm -p 8080:8080 sample_app:v1
	- curl localhost:8080

# Access from local PC
  - curl 169.254.169.254/latest/meta-data/public-ipv4
  - ブラウザで http://IP:8080 へアクセス

# Terraform ECR
	- cd ~/environment/aws-training/terraform/ecr
	- terraform init
	- terraform plan --var "name=$MY_NAME"
	- terraform apply --var "name=$MY_NAME"
  - ECR_URL=$(terraform show | grep repository_url | sed -e 's/.* = //g')

# Push to ECR
  - $(aws ecr get-login --no-include-email --region ap-northeast-1)
  - cd ~/environment/$MY_NAME
  - docker build -t $MY_NAME .
  - docker tag $MY_NAME:latest $ECR_URL:v1.0
  - docker push $ECR_URL:v1.0

# Create ECS Task
  - ECS -> Task Definitions
    - Create New task
      - EC2
        - Name
          - myname
        - Role
          - ecsTaskExecutionRole
        - Network
          - bridge
        - TaskExecRole
          - EcsTaskExecutionRole
        - Memory
          - 64
        - CPU
          - 128
        - Container Def
          - Name
            - webapp
          - Image
            - repository-url/tag
        - Port Mapping
          - Host Port
            - nnn
          - Container Port
            - 8080
  - ECS -> Cluster aws-traing
    - task
      - execute new task
        - type
          - EC2
        - Task Def
          - myname
        - cluster
          - aws-training
        - task num
          - 1

# 動作検証
  - ローカルPCからEC2のIP:HostPortへアクセスする
  - ECSクラスターでDockerImageが実行されている状態
  - NonHAな検証も行う

# Prepareing
  - EC2クラスター増設

# Create ECS Service
  - ECS -> Cluster aws-traing
    - Service
      - Type
        - EC2
      - Task Def
        - myname
      - Cluster
        - aws-training
      - ServiceName
        - myname
      - ServiceType
        - Replica
      - Task Num
        - 2
      - Min Health
        - 100
      - Max Health
        - 200
      - ELB
        - ALB
      - Role
        - AWSServiceRoleForECS
      - ELBName
        - aws-training
      - Container
        - Listenerport
          - nnnn
      - Servie検出
        - Off
        
# 動作検証
  - ローカルPCからALBのIP:HostPortへアクセスする
  - ECSクラスターでDockerImageが実行されている状態
  - HAな検証も行う

# Update Sample app
	- cd ~/environment/$MY_NAME
  - sed -e 's/Ok/Hello World/g' -i main.go
  - docker build -t $MY_NAME:v2.0 .
	- docker run --rm -p 8080:8080 $MY_NAME:v2.0
  - git add -A
  - git commit -m 'v2'
  - git push origin master
  

# Build Docker Pipeline
	- cd ~/environment/aws-training/terraform/build_docker_pipeline
	- terraform init
  - terraform plan -var "name=$MY_NAME" -var "repoName=$MY_NAME" -var "branchName=master" -var "serviceName=$MY_NAME"
  - terraform apply -var "name=$MY_NAME" -var "repoName=$MY_NAME" -var "branchName=master" -var "serviceName=$MY_NAME"

# 動作検証
  - ローカルPCからALBのIP:HostPortへアクセスする
  - 無停止デプロイなことを検証
