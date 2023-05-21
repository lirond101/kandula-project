FROM jenkins/jenkins:lts-jdk11
MAINTAINER lirond101@gmail.com
USER root

COPY --chown=jenkins:jenkins jenkins-plugins.txt /usr/share/jenkins/ref/jenkins-plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/jenkins-plugins.txt

# copy seedjob
COPY --chown=jenkins:jenkins kandula-pipeline/config.xml /usr/share/jenkins/ref/jobs/kandula-pipeline/config.xml

# # docker build --build-arg admin_username=${VARIABLE_NAME} --build-arg admin_password=${VARIABLE_NAME}(...)
ARG admin_username
ARG admin_password

# #Update the username and password
ENV JENKINS_USER $admin_username
ENV JENKINS_PASS $admin_password

#id_rsa.pub file will be saved at /root/.ssh/
RUN ssh-keygen -f $HOME/.ssh/id_rsa -t rsa -N ''

# allows to skip Jenkins setup wizard
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

# Jenkins runs all groovy files from init.groovy.d dir
# use this for creating default admin user
COPY default-user.groovy /usr/share/jenkins/ref/init.groovy.d/

VOLUME /var/jenkins_home
USER jenkins