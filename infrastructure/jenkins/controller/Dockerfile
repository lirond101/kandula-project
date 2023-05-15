FROM jenkins/jenkins:lts-jdk11
MAINTAINER lirond101@gmail.com
USER root

# RUN apt-get update && \
#     apt-get -y install apt-transport-https \
#       ca-certificates \
#       curl \
#       gnupg2 \
#       software-properties-common && \
#     curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg > /tmp/dkey; apt-key add /tmp/dkey && \
#     add-apt-repository \
#       "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
#       $(lsb_release -cs) \
#       stable" && \
#    apt-get update && \
#    apt-get -y install docker-ce

# # install jenkins plugins
# COPY ./jenkins-plugins /usr/share/jenkins/plugins
# RUN while read i ; \
#                 do /usr/local/bin/install-plugin-cli.sh $i ; \
#         done < /usr/share/jenkins/plugins

#TODO remove unnecessary plugins - ssh, docker (unless I eventually use docker plugin instead od dind)
COPY --chown=jenkins:jenkins jenkins-plugins.txt /usr/share/jenkins/ref/jenkins-plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/jenkins-plugins.txt

# docker build --build-arg admin_username=${VARIABLE_NAME} --build-arg admin_password=${VARIABLE_NAME}(...)
ARG admin_username
ARG admin_password

#Update the username and password
ENV JENKINS_USER $admin_username
ENV JENKINS_PASS $admin_password

#id_rsa.pub file will be saved at /root/.ssh/
RUN ssh-keygen -f /root/.ssh/id_rsa -t rsa -N ''

# allows to skip Jenkins setup wizard
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

# Jenkins runs all groovy files from init.groovy.d dir
# use this for creating default admin user
COPY default-user.groovy /usr/share/jenkins/ref/init.groovy.d/

VOLUME /var/jenkins_home