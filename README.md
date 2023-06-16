# kandula-project

# What Is This Project?
This project support the running and maintaining kandula web-app. (https://github.com/lirond101/kandula-app-9).
This process is established by CI/CD flow managed by Jenkins which run on container inside the EKS.
The project is mainly built from terraform files and few more provisioning files which on future will be integrated into terraform files.

# How to run?
## Your variables
1. Please change the variables.tf and tfvars.tf files with your requested variables.
2. ## Run Terraform on each:
   1. kandula-project/infrastracture/aws/vpc
   2. kandula-project/infrastracture/aws/ec2
   3. kandula-project/infrastracture/aws/eks
```shell script
   $ terraform init
   $ terraform apply --auto-approve
   ```

3. Please replace the domain with the your own in the ingress yaml files.
4. ## Provision
```shell script
   $ cd kandula-project/infrastracture/k8s
   $ ./setup <eks-cluster-name> <aws-region> 
   ```
   *eks-cluster-name you will see as output of success terraform run.
5. Update domain registar with the CNAME value of your ingress output.
6. Configure Jenkins
    6.1. Go to http://<your-domain>/jenkins.
    6.2. Add admin username and password.
    6.3. Configure k8s cloud - (k8s plugin for jenkins is already installed see here for installed plugins - https://github.com/lirond101/kandula-project/blob/vpc/infrastructure/jenkins/controller/jenkins-plugins.txt)
        6.3.1. Jenkins URL: http://<your-domain>/jenkins
        6.3.2. Jenkins tunnel: jenkins-svc.jenkins.svc.cluster.local:50000
        6.3.3. Credentials of secret text - K8s jenkins service account -use the JWT which ./setup from step 4 outputs.
    6.4. Store credentials for Jenkins pipeline:
        6.4.1. Dockerhub  - username / password.
        6.4.2. Github - SSH key - generate key pair and store here its private part and on Github at SSH and GPG store the public part.
            6.4.2.1 - Go to global credentials and update the github known keys - I prefer to choose "provide it manually" and put there the response of:
            ```shell script
               $ ssh-keyscan github.com
            
8. Configure db.
   ```shell script
   $ ansible-inventory -i db_aws_ec2.yml --graph
   $ ansible-playbook playbook_postgres.yml -i db_aws_ec2.yml
   $ ansible-playbook playbook_clients.yml -i db_aws_ec2.yml
   ```

9. Go to http://your-domain>/ and enjoy with kandula.
10. ## SSH
```shell script
   $ chmod 400 your_aws_ec2_key.pem
   $ ssh-add -k ~/.ssh/your_aws_ec2_key.pem
   $ ssh -A <user>@<bastion-ip>
   $ ssh <user>@<private-instance-ip>
   ```
10. ## Connect PostgreSQL client through SSH tunnel into db
```shell script
   $ chmod 400 your_aws_ec2_key.pem
   $ ssh-add -k ~/.ssh/your_aws_ec2_key.pem
   $ ssh -L <local-port>:<db-server-ip-addr>:<db-port> <ssh-user>@<ssh-server-ip-addr>(:<ssh-port>)
   $ psql -p <local-port> -U <user> -d <db> -h localhost
   ```
  Note, the above assumes we use openssh implementations (https://stackoverflow.com/questions/17846529/could-not-open-a-connection-to-your-authentication-agent)
  if not run this:
     $ export SSHAGENT=/usr/bin/ssh-agent
     $ export SSHAGENTARGS="-s"