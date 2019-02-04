FROM golang:1.11.0

ENV LC_ALL=C.UTF-8 \
    LANG=C.UTF-8

RUN apt-get update \
  && env DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
       python3 python3-pip python3-venv zip unzip upx shellcheck jq gettext-base rsync uuid-runtime\
  && echo "deb http://ftp.us.debian.org/debian testing main contrib non-free" >> /etc/apt/sources.list \
  && apt-get update \
  && env DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
       git \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir /.cache && chmod 777 /.cache \
  && mkdir /.npm && chmod 777 /.npm \
  && mkdir /.dcos && chmod 777 /.dcos \
  && pip3 install setuptools wheel \
  && pip3 install pre-commit gitlint awscli

ARG DCOS_CLI_URL=https://downloads.dcos.io/binaries/cli/linux/x86-64/0.7.5/dcos
ARG DOCKER_URL=https://download.docker.com/linux/static/stable/x86_64/docker-17.12.0-ce.tgz
ARG TERRAFORM_URL=https://releases.hashicorp.com/terraform/0.11.11/terraform_0.11.11_linux_amd64.zip
ARG HUB_URL=https://github.com/github/hub/releases/download/v2.8.4/hub-linux-amd64-2.8.4.tgz

RUN curl -sL $DCOS_CLI_URL -o /usr/local/bin/dcos && \
    chmod +x /usr/local/bin/dcos

RUN curl -sL $DOCKER_URL -o /docker.tgz && \
    tar -xzvf /docker.tgz -C /usr/local/bin --strip 1 && \
    rm -f /docker.tgz

RUN curl -sL $TERRAFORM_URL -o /terraform.zip && \
    unzip -d /usr/local/bin /terraform.zip && \
    rm -f /terraform.zip

RUN curl -sL $HUB_URL -o /hub.tgz && \
    tar -xzvf /hub.tgz -C /usr/local --strip 1 && \
    rm -f /hub.tgz

ADD user-init.sh /user-init.sh

ARG USER_NAME=root
ARG USER_ID=0
ARG GROUP_NAME=root
ARG GROUP_ID=0

RUN /user-init.sh $USER_NAME $USER_ID $GROUP_NAME $GROUP_ID
RUN rm -f /user-init.sh

WORKDIR /

CMD ["/bin/bash"]

ARG PACKAGE_NAME
ARG PACKAGE_VERSION

LABEL Name="${PACKAGE_NAME}-dev"
LABEL Description="Development Docker image for ${PACKAGE_NAME}."
LABEL Version="0.1.0"
