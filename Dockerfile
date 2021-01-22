FROM docker.io/golang:1.14-alpine

ARG VERSION=4.6
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000

RUN addgroup -g ${gid} ${group}
RUN adduser -h /home/${user} -u ${uid} -G ${group} -D ${user}
LABEL Description="This is a base image, which provides the Jenkins agent executable (slave.jar)" Vendor="Jenkins project" Version="${VERSION}"

ARG AGENT_WORKDIR=/home/${user}/agent

RUN apk add --update --no-cache curl bash git git-lfs openssh-client openssl procps openjdk11 \
  && curl --create-dirs -fsSLo /usr/share/jenkins/agent.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/agent.jar \
  && ln -sf /usr/share/jenkins/agent.jar /usr/share/jenkins/slave.jar 

USER ${user}
ENV AGENT_WORKDIR=${AGENT_WORKDIR}
RUN mkdir /home/${user}/.jenkins && mkdir -p ${AGENT_WORKDIR}

VOLUME /home/${user}/.jenkins
VOLUME ${AGENT_WORKDIR}
WORKDIR /home/${user}


ARG user=jenkins

USER root
#COPY jenkins-agent /usr/local/bin/jenkins-agent
RUN curl -fsSLo /usr/local/bin/jenkins-agent https://raw.githubusercontent.com/jenkinsci/docker-inbound-agent/master/jenkins-agent
RUN chmod +x /usr/local/bin/jenkins-agent &&\
    ln -s /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-slave

USER ${user}

RUN go get -u go.mongodb.org/mongo-driver/mongo && \
    go get -u github.com/gin-gonic/gin && \
    go get -u github.com/go-playground/locales && \
    go get -u github.com/go-playground/universal-translator && \
    go get -u github.com/gomodule/redigo/redis && \
    go get -u github.com/google/go-querystring/query && \
    go get -u github.com/leodido/go-urn && \
    go get -u github.com/nu7hatch/gouuid && \
    go get -u github.com/patrickmn/go-cache && \
    go get -u github.com/pkg/errors && \
    go get -u github.com/robfig/cron && \
    go get -u github.com/stretchr/testify && \
    go get -u gopkg.in/go-playground/validator.v9
    
ENTRYPOINT ["jenkins-agent"]