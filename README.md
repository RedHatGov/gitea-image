# Gitea for OpenShift

Gitea is a Git service. Learn more about it [here](https://gitea.io/en-US/).

Running containers on OpenShift comes with certain security and other requirements. This repository contains:

* A Dockerfile for building an OpenShift-compatible Gitea image
* The run scripts used in the Docker image
* An example configuration file that you should edit
* A simple docker-compose.yml for testing (admittedly for use with [podman compose](https://github.com/containers/podman-compose))

## Prerequisites

### OpenShift Deployment

* An account in an OpenShift 4.X environment and a project
* Gitea requires a database to store its information. Provisioning a database is out-of-scope for this repository. If you wish to run the database on OpenShift, it is suggested that you deploy PostgreSQL using persistent storage. More information on the containerized PostgreSQL deployment tested with this project is available [here](https://catalog.redhat.com/software/containers/rhel8/postgresql-10/5ba0ae0ddd19c70b45cbf4cd).

### Local Deployment

* `podman` and `podman-compose` installed.
* `cp example.app.ini app.ini` and make appropriate edits for your environment.

## Operator Deployment

A Gitea Operator can be found [here](https://github.com/RedHatGov/gitea-operator). Operators are the preferred way to deploy complex stateful applications on Kubernetes.

## Local Testing

To stand up Gitea for local testing of the image, on first run you should do:

```shell
GITEA_SETUP=TRUE GITEA_ADMIN_PASSWORD=password podman-compose up -d
```

For all subsequent starts after `podman-compose down` you can leave off the environment variables and simply use `podman-compose up -d` until you do a `podman volume prune` and drop the database data from the setup run.
