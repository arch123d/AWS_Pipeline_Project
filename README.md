# AWS_Pipeline_Project
AWS Services use in this Project
1. AWS CodeCommit
2. AWS CodeBuild
3. AWS CodeDeploy
4. AWS CodePipeline
5. AWS EC2 (Ubuntu Instances)
6. AWS S3
7. AWS IAM (Role and User)
   
# Step to Create AWS Pipeline
## Create Repo on CodeCommit take access on your VScode
1. Give Name to It MyProjectrepo
2. Create User that is Pipeline-user
3. Create Codecommit Credentions of this user
4. Give Adminfullaccess Permission to this user
5. Copy Repo Https Clone URL
6. Clone it on your local environment Give codecommit username and password for login
7. Go to in clone repo Create Bellow Files
## File you must prepared for this Porject
1. index.html
```
cat > index.html
<html><title>Shan</title>
<body>
    <h1> AWS Pipeline $localhost</h1>
</body>
</html> 
```
2. buildspec.yml
```
cat > buildspec.yml
version: 0.2

phases:
  install:
    commands:
      - echo "Installing nginx"
      - sudo apt-get update
      - sudo apt-get install nginx -y
  build:
    commands:
      - echo "Build started on $(date)"
      - sudo cp index.html /var/www/html/
artifacts:
  files:
    - '**/*'
```
3. appspec.yml
```
cat > appspec.yml
version: 0.0
os: linux
files:
  - source: /
    destination: /var/www/html
hooks:
  AfterInstall:
    - location: install-nginx.sh
      timeout: 300
      runas: root
  ApplicationStart:
    - location: start-nginx.sh
      timeout: 300
      runas: root
 ```
4. install-nginx.sh
```
#!/bin/bash
sudo apt-get update
sudo apt-get install -y nginx
```
5. start-nginx.sh
```
#!/bin/bash
sudo service nginx start
```
# Create Build Project
1. Navigate to CodeBuild in the AWS Management Console.
2. Click Create Build Project.
3. Configure the project:
Project Name: MyAppBuild

Source Provider: CodeCommit

Repository: Select the repository created in Step 1.

Environment: Select a managed image (e.g., Ubuntu).

Buildspec: Add a buildspec.yml file in your repository for the build instructions.

5. Create S3 Bucket MyProjectBucket
6. In Artifacts:

Choose Amazon S3.

Select the bucket created in Step 2 for storing the build output.
# Create an AWS CodeDeploy Application
This step involves setting up AWS CodeDeploy to deploy your application on EC2 instances.

## Step-by-Step Guide:
Navigate to CodeDeploy:

Open the AWS Management Console.

In the search bar, type CodeDeploy and select it.

Create the CodeDeploy Application:

Click on Create Application.

Application Name: Enter a name for the application (e.g., MyAppDeploy).

Compute Platform: Select EC2/On-Premises as the platform because we are deploying to EC2 instances.
# When We Create Instance Put Bellow File in USERDATA
2. codedeploy-agent-install.sh (Note: Used Ubuntu Image)
```
#!/bin/bash 
# This installs the CodeDeploy agent and its prerequisites on Ubuntu 22.04.  
sudo apt-get update 
sudo apt-get install ruby wget -y 
cd /tmp
# wget https://bucket-name.s3.region-identifier.amazonaws.com/latest/install
wget https://aws-codedeploy-ap-south-1.s3.ap-south-1.amazonaws.com/latest/install
sudo chmod +x ./install
sudo ./install auto
sudo service codedeploy-agent start
sudo systemctl enable codedeploy-agent
sudo service codedeploy-agent status
```


Create a Deployment Group:

Deployment Group Name: Enter a name for the deployment group (e.g., MyAppDeploymentGroup).

# Service Role: This is the IAM role that gives CodeDeploy permissions to deploy to your EC2 instances. Create a new role if you don't have one:

Go to IAM and create a role with the service CodeDeploy.

Attach the following policies to the role:
```
AWSCodeDeployRole

AmazonEC2RoleforAWSCodeDeploy
```
Deployment Type:
Choose:

Amazon EC2 Instances: Choose how the EC2 instances should be selected for deployment:

Tag Key/Value: You can select the EC2 instances by tags (e.g., Key: app, Value: MyApp).

Choose:

All-at-once: Deploy to all instances simultaneously (results in a faster deployment but may cause more downtime).

One-at-a-time: Deploy to one instance at a time, ensuring that at least some instances remain up during deployment.

Create the Application:

Click Create Application once the configuration is complete.
# Create AWS CodePipeline
Now, let's set up the CodePipeline that will automate the deployment process from CodeCommit (source), to CodeBuild (build), and finally to CodeDeploy (deploy to EC2).

Step-by-Step Guide:
Navigate to CodePipeline:

Open the AWS Management Console.

In the search bar, type CodePipeline and select it.

Create a Pipeline:

Click on Create Pipeline.

Pipeline Name: Enter a name for the pipeline (e.g., MyAppPipeline).

Service Role: You can either:

Use an existing role if you have a pre-configured IAM role.
Or, let CodePipeline create a new service role with the necessary permissions.

Artifact Store:

This is where the build artifacts (like the .zip file created by CodeBuild) will be stored.
Choose Amazon S3 as the artifact store.
Select the S3 bucket created earlier in Step 2 (myapp-build-artifacts).
#### 1. Source Stage:

This stage pulls the source code from CodeCommit.

Source Provider: Select AWS CodeCommit.

Repository Name: Select the repository created in Step 1 (MyAppRepo).

Branch Name: Choose the branch from which you want to pull the source code (e.g., master).

Click Next to proceed to the next stage.

#### 2. Build Stage:

This stage uses CodeBuild to build the application and create the .zip file.

Build Provider: Select AWS CodeBuild.

Project Name: Select the build project you created earlier (MyAppBuild).

CodeBuild will use the buildspec.yml file from the source repository to determine the build steps and create the output artifact.

Click Next to proceed to the next stage.

#### 3. Deploy Stage:

This stage uses CodeDeploy to deploy the build artifact to EC2 instances.

Deploy Provider: Select AWS CodeDeploy.

Application Name: Select the CodeDeploy application you created earlier (MyAppDeploy).

Deployment Group: Select the deployment group created earlier (MyAppDeploymentGroup).

CodeDeploy will now use the deployment settings specified (e.g., One-at-a-time or Blue/Green).

Review and Create the Pipeline:

Review all the settings and click Create Pipeline.
The pipeline will automatically start and execute the defined stages. 

## Fire Following Command in every EC2 instance which in deployment group
```
sudo service codedeploy-agent restart
```

# Finally Hit Instance IP Check Your Index.html Show Or Not
![Screenshot (1206)](https://github.com/user-attachments/assets/8c132d8c-2aeb-4a3c-8594-b373d01c5130)







