# Devops Project: video-converter
**Converting mp4 videos to mp3 audio in a microservices architecture,
deploying a Python-based Microservice Application on AWS EKS**
       
## Table of Contents:
1. Architecture
2. Introduction
3. Prerequisites
4. Getting Started
5. High Level steps 
6. Low Level Steps
7. API Definition
8. Contact


## Architecture

<p align="center">
  <img src="./Project documentation/ProjectArchitecture.png" width="600" title="Architecture" alt="Architecture">
  </p>


### Introduction

This document provides a step-by-step guide for deploying a Python-based microservice application on AWS Elastic Kubernetes Service (EKS). The application comprises four major microservices: `auth-server`, `converter-module(login,upload,download)`, `database-server` (PostgreSQL and MongoDB), and `notification-server`.

### Prerequisites

Before you begin, ensure that the following prerequisites are met:

1. **Create an AWS Account:** If you do not have an AWS account, create one by following the steps [here](https://docs.aws.amazon.com/streams/latest/dev/setting-up.html).

2. **Install Helm:** Helm is a Kubernetes package manager. Install Helm by following the instructions provided [here](https://helm.sh/docs/intro/install/).

3. **Python:** Ensure that Python is installed on your system. You can download it from the [official Python website](https://www.python.org/downloads/).

4. **AWS CLI:** Install the AWS Command Line Interface (CLI) following the official [installation guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).

5. **Install kubectl:** Install the latest stable version of `kubectl` on your system. You can find installation instructions [here](https://kubernetes.io/docs/tasks/tools/).

6. **Databases:** Set up PostgreSQL and MongoDB for your application.

7. **Docker:** Ensure that docker downloaded , or you can download from [here](https://docs.docker.com/engine/install/ubuntu/) for ubuntu

### Getting Started
### High Level steps (Flow of Application Deployment)

Follow these steps to deploy your microservice application:

1. **MongoDB and PostgreSQL Setup:** Create databases and enable automatic connections to them.

2. **RabbitMQ Deployment:** Deploy RabbitMQ for message queuing, which is required for the `converter-module`.

3. **Create Queues in RabbitMQ:** Before deploying the `converter-module`, create two queues in RabbitMQ: `mp3` and `video`.

4. **Deploy Microservices:**
   - **auth-server:** Navigate to the `auth-server` manifest folder and apply the configuration.
   - **gateway-server:** Deploy the `gateway-server`.
   - **converter-module:** Deploy the `converter-module`. 
   - **notification-server:** Configure email for notifications and two-factor authentication (2FA).Make sure to provide your email and password in `notification/manifest/secret.yaml`.

5. **Application Validation:** Verify the status of all components by running:
   ```bash
   kubectl get all
   ```
    Ensure form pv and pvc are bound

   ```bash
   kubectl get pv 
   ```
6. **Destroying the Infrastructure**  fron console



### Low Level Steps

#### 1. Cluster Creation

1. **Log in to AWS Console:**
   - Access the AWS Management Console with your AWS account credentials(Access key and Secret access key).

2. **Create eksCluster IAM Role**
   - Follow the steps mentioned in [this](https://docs.aws.amazon.com/eks/latest/userguide/service_IAM_role.html) documentation using root user , role have `AmazonEKSClusterPolicy` , `AmazonEKS_CNI_Policy `
   - After creating it will look like this:

   <p align="center">
  <img src="./Project documentation/ekscluster_role.png" width="600" title="ekscluster_role" alt="ekscluster_role">
  </p>

3. **Open EKS Dashboard:**
   - Navigate to the Amazon EKS service from the AWS Console dashboard.

4. **Create EKS Cluster:**
   - Click "Create cluster."
   - Choose a name for your cluster.
   - Configure networking settings (default VPC, public subnets only).
   - attach default security group
   - Choose the `eksCluster` IAM role that was created above
   - Review and create the cluster.

5. **Cluster Creation:**
   - Wait for the cluster to provision, which may take several minutes.

6. **Cluster Ready:**
   - Once the cluster status shows as "Active," you can now create node groups.

#### 2. Node Group Creation

1. Click "Create node group."
2. In the "Compute" section, click on "Add node group."

3. **Create Node Role - AmazonEKSNodeRole**
   - Follow the steps mentioned in [this](https://docs.aws.amazon.com/eks/latest/userguide/create-node-role.html#create-worker-node-role) documentation using root user
   - Please note that you do NOT need to configure any VPC CNI policy mentioned after step 5.e under Creating the Amazon EKS node IAM role
   - Simply attach the following policies to your role once you have created `AmazonEKS_CNI_Policy` , `AmazonEBSCSIDriverPolicy` , `AmazonEC2ContainerRegistryReadOnly` , `AmazonEKSWorkerNodePolicy`
    
     incase it is not attached by default
   - Your AmazonEKSNodeRole will look like this: 

<p align="center">
  <img src="./Project documentation/node_iam.png" width="600" title="Node_IAM" alt="Node_IAM">
  </p>
4. Choose the AMI (default), instance type (e.g., t3.medium), and the number of nodes (attach a screenshot here).

5. Adding inbound rules in Security Group of Nodes

**NOTE:** Ensure that all the necessary ports are open in the node security group.

<p align="center">
  <img src="./Project documentation/inbound_rules_sg.png" width="600" title="Inbound_rules_sg" alt="Inbound_rules_sg">
  </p>

6. enable addon `ebs csi` this is for enabling pvcs once cluster is created

<p align="center">
  <img src="./Project documentation/ebs_addon.png" width="600" title="ebs_addon" alt="ebs_addon">
  </p>

7. **NodeGroup Ready:**
   - Once the NodeGroup status shows as "Active," you can now start deploy.

#### 3. Deploying your application on EKS Cluster

1. Clone the code from this repository.
 Clone the repository.
   ```sh
   git clone https://github.com/Mohamed-Tharwat-El-Sayed/microservices-python-app.git

2. Set the cluster context:
   ```
   aws eks update-kubeconfig --name <cluster_name> --region <aws_region>
   ```


### MongoDB

To install MongoDB, set the database username and password in `values.yaml`, then navigate to the MongoDB Helm chart folder and run:

```
cd Helm_charts/MongoDB
helm install mongo .
```

Connect to the MongoDB instance using:
you can get nodeip form your instance in your node.

```
mongosh mongodb://<username>:<pwd>@<nodeip>:30005/mp3s?authSource=admin
```

### PostgreSQL

Set the database username and password in `values.yaml`. Install PostgreSQL from the PostgreSQL Helm chart folder and initialize it with the queries in `init.sql`. For PowerShell users:

```
cd Helm_charts/Postqres
helm install postgres .
```

Connect to the Postgres database and copy all the queries from the "init.sql" file.
```
psql 'postgres://<username>:<pwd>@<nodeip>:30003/authdb'
```

### RabbitMQ

Deploy RabbitMQ by running:

```
cd Helm_charts/Rabbitmq
helm install rabbitmq .
```

Ensure you have created two queues in RabbitMQ named `mp3` and `video`. To create queues, visit `<nodeIp>:30004` in browser and use default username `guest` and password `guest`

**NOTE:** Ensure that all the necessary ports are open in the node security group.

### Apply the manifest file for each microservice:

- **Auth Service:**
  ```
  cd auth-service/manifest
  kubectl apply -f .
  ```

- **Gateway Service:**
  ```
  cd gateway-service/manifest
  kubectl apply -f .
  ```

- **Converter Service:**
  ```
  cd converter-service/manifest
  kubectl apply -f .
  ```

- **Notification Service:**
  ```
  cd notification-service/manifest
  kubectl apply -f .
  ```

### Application Validation

After deploying the microservices, verify the status of all components by running:

```
kubectl get all
kubectl get pv
```

### Notification Configuration

For configuring email notifications and two-factor authentication (2FA), follow these steps:
1. Go to your Google Account.
2. Select Security.
3. Under "Signing in to Google," select 2-Step Verification.
4. At the bottom of the page, select App passwords.
5. Enter a name that helps you remember where you’ll use the app password.
6. Select Generate.
7. To enter the app password, follow the instructions on your screen. The app password is the 16-character code that generates on your device.
8. Select Done.
9. Paste this generated password in `notification/manifest/secret.yaml` along with your email.

Run the application through the following API calls:

# API Definition

- **Login Endpoint**
  ```http request
  POST http://nodeIP:30002/login
  ```
put you email and password of your email which is on Postqrss 

  ```console
  curl -X POST http://nodeIP:30002/login -u <email>:<password>
  ``` 
  Expected output: success!

- **Upload Endpoint**
  ```http request
  POST http://nodeIP:30002/upload
  ```

  ```console
   cd ~/microservices-python-app/myvideo/
   curl -X POST -F 'file=@./video.mp4' -H 'Authorization: Bearer <JWT Token>' http://nodeIP:30002/upload
  ``` 
  
  Check if you received the ID on your email.

- **Download Endpoint**
  ```http request
  GET http://nodeIP:30002/download?fid=<Generated file identifier>
  ```
  ```console
   curl --output video.mp3 -X GET -H 'Authorization: Bearer <JWT Token>' "http://nodeIP:30002/download?fid=<Generated fid>"
  ``` 

## Destroying the Infrastructure

To clean up the infrastructure, follow these steps:

1. **Delete the Node Group:** Delete the node group associated with your EKS cluster.

2. **Delete the EKS Cluster:** Once the nodes are deleted, you can proceed to delete the EKS cluster itself.
   
## Contact

For inquiries, please contact [Mohamed Tharwat] at [Mohammed.Tharwat.Elsayed@gmail.com].
