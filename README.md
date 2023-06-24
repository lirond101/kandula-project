# kandula-project

## What Is This Project?
This project support the running and maintaining kandula web-app. (https://github.com/lirond101/kandula-app-9).
This process is established by CI/CD flow managed by Jenkins which run on container inside the EKS.
The project is mainly built from terraform files and few more provisioning files which on future will be integrated into terraform files.

## How to run?
### Your variables
Please change variables here:
 1. Terraform - variables.tf and tfvars.tf.
 2. Ansible playbook - path/to/ansible/role/defaults/main.yml

### Setup project
```shell script
$ chomod +x kandula.sh
$ ./kandula.sh
```
### Provision
#### Dockerize Jenkins
```shell script
$ docker build -t <repo-dockerhub>/<container-name>:<tag> . --no-cache
```

#### Configure Jenkins
   1. Go to http://<your-domain>/jenkins.
   2. Add admin username and password.
   3. Configure k8s cloud - (k8s plugin for jenkins is already installed see here for installed plugins - https://github.com/lirond101/kandula-project/blob/vpc/infrastructure/jenkins/controller/jenkins-plugins.txt)

      3.1. Jenkins URL: http://<your-domain>/jenkins

      3.2. Jenkins tunnel: jenkins-svc.jenkins.svc.cluster.local:50000

      3.3. Credentials of secret text - K8s jenkins service account -use the JWT which ./setup from step 4 outputs.
   4. Store credentials for Jenkins pipeline:

      4.1. Dockerhub  - username / password.

      4.2. Github - SSH key - generate key pair and store here its private part and on Github at SSH and GPG store the public part.

      4.3. Go to global credentials and update the github known keys - I prefer to choose "provide it manually" and put there the response of:
         ```shell script
            $ ssh-keyscan github.com
         ```

### SSH
```shell script
$ chmod 400 your_aws_ec2_key.pem
$ ssh-add -k ~/.ssh/your_aws_ec2_key.pem
$ ssh -A <user>@<bastion-ip>
$ ssh <user>@<private-instance-ip>
```
### Connect PostgreSQL client through SSH tunnel into db
```shell script
$ eval "$(ssh-agent)"
$ echo $SSH_AUTH_SOCK
$ chmod 400 your_aws_ec2_key.pem
$ ssh-add -k ~/.ssh/your_aws_ec2_key.pem
$ ssh -L <local-port>:<db-server-ip-addr>:<db-port> <ssh-user>@<ssh-server-ip-addr>(:<ssh-port>)
$ psql -p <local-port> -U <user> -d <db> -h localhost
```
Note, the above assumes we use openssh implementations (https://unix.stackexchange.com/questions/48863/ssh-add-complains-could-not-open-a-connection-to-your-authentication-agent)

### Go to http://your-domain>/ and enjoy with kandula.
