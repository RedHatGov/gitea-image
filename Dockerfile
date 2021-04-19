# Use Red Hat Universal Base Image 8 - Minimal
FROM registry.access.redhat.com/ubi8/ubi-minimal:latest

# Set the Gitea Version to install.
# Check https://dl.gitea.io/gitea/ for available versions.
ARG GITEA_VERSION="1.13.2"
ARG APP_HOME=/home/gitea
ARG REPO_HOME=/gitea-repositories

ENV GITEA_VERSION=$GITEA_VERSION \
    APP_HOME=$APP_HOME \
    GITEA_CONFIG=$APP_HOME/conf/app.ini \
    REPO_HOME=$REPO_HOME \
    GITEA_ADMIN_USERNAME=administrator \
    GITEA_ADMIN_EMAIL=administrator@gitea.fq.dn \
    GITEA_ADMIN_PASSWORD="" \
    GITEA_SETUP=""

LABEL name="Gitea - Git with a cup of tea" \
      vendor="Gitea" \
      io.k8s.display-name="Gitea - Git Service" \
      io.openshift.expose-services="3000:http,2022:ssh" \
      io.openshift.tags="gitea" \
      io.gitea.version=$GITEA_VERSION \
      release="1" \
      maintainer="James Harmison <jharmison@redhat.com>"

# Load entrypoint and example config
COPY ./root /

# Update latest packages, install prerequisites, create the user, download the
#   application, and set permissions
RUN set -ex \
    && microdnf -y update \
    && microdnf -y install \
        git \
        ca-certificates \
        openssh \
        gettext \
        openssh \
        tzdata \
    && microdnf -y clean all \
    && rm -rf /var/cache/yum \
    && adduser --comment Gitea \
        --home-dir ${APP_HOME} \
        --create-home \
        --uid 1001 \
        --user-group \
        gitea \
    && mkdir -p \
        ${REPO_HOME} \
        ${APP_HOME}/data/lfs \
        ${APP_HOME}/conf \
        /.ssh \
    && chmod -R u=rwX,g=rwX,o=rX \
        /etc/passwd \
        /.ssh \
        ${APP_HOME} \
        ${REPO_HOME} \
    && chown -R 1001:0 \
        /etc/passwd \
        ${APP_HOME} \
        ${REPO_HOME} \
    && curl -Lo \
        ${APP_HOME}/gitea \
        https://dl.gitea.io/gitea/${GITEA_VERSION}/gitea-${GITEA_VERSION}-linux-amd64 \
    && chmod 775 \
        ${APP_HOME}/gitea

WORKDIR ${APP_HOME}
VOLUME ${REPO_HOME}
EXPOSE 2022 3000
USER 1001

ENTRYPOINT ["/usr/bin/rungitea"]
