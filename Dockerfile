FROM openjdk:8-jdk

ARG user=ec2-user
ARG uid=10000
ARG group=jenkins
ARG gid=10000

ENV HOME /home/${user}

RUN groupadd -g ${gid} ${group}
RUN useradd -c "Jenkins USer" -d $HOME -u ${user} -g ${gid} -m ${user}

ARG VERSION=3.20
ARG AGENT_WORKDIR=/home/${user}/agent

RUN curl --create-dirs -sSLo /usr/share/jenkins/slave.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar \
    && chmod 755 /usr/share/jenkins \
    && chmod 644 /usr/share/jenkins/slave.jar
    
USER ${user}
ENV AGENT_WORKDIR=${AGENT_WORKDIR}

RUN mkdir /home/${user}/.jenkins && mkdir -p ${AGENT_WORKDIR}
COPY jenkins-slave /usr/local/bin/jenkins-slave

WORKDIR /home/${user}
RUN git config --global user.name abdulraheem6 \
    && git config --global user.email moise1445@gmail.com

RUN ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -P "" \
    && eval "$(ssh-agent -s)" \
    && ssh-add ~/.ssh/id_rsa
    
USER root

#RUN mkdir -p /usr/lib/jvm
RUN ln -s /usr/lib/jvm/java-8-openjdk-amd64 /usr/lib/jvm/java8
ENV JAVA_HOME /usr/lib/jvm/java8

##COPY Certs /home/ec2-user/.certs/
##RUN cp /home/ec2-user/.certs/* /usr/local/share/ca-certificates

##RUN update-ca-certificates

##RUN cd /home/ec2-user/.certs \
    && printf '1' | java InstallCert nexus.com:443 \
    && printf '1' | sonar.com \
    && printf '1' | servicenow.com \
    && printf '1' | jira.com \
    && cp jssecacerttifcate /$JAVA_HOME/jre/lib/security/
    



#install certs 

##RUN keytool -import -noprompt -alias momosroot -keystore $JAVA_HOME/jre/lib/security/cacerts -storepass changeit -trustcacerts -file "/home/ec2-user/.certs/momosrootCA.cer"
##RUN keytool -import -noprompt -alias momosinter -keystore $JAVA_HOME/jre/lib/security/cacerts -storepass changeit -trustcacerts -file "/home/ec2-user/.certs/momosISsueingCA.cer"
##RUN keytool -import -noprompt -alias nexus.com -keystore $JAVA_HOME/jre/lib/security/cacerts -storepass changeit -trustcacerts -file "/home/ec2-user/.certs/nexus.com.pem"

ENTRYPOINT ["jenkins-slave"]
