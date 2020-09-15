# Gitea for OpenShift

Gitea is a Git service. Learn more about it [here](https://gitea.io/en-US/).

Running containers on OpenShift comes with certain security and other requirements. This repository contains:

* A Dockerfile for building an OpenShift-compatible Gitea image
* The run scripts used in the Docker image

## Prerequisites

* An account in an OpenShift 4.X environment and a project
* Gitea requires a database to store its information. Provisioning a database is out-of-scope for this repository. If you wish to run the database on OpenShift, it is suggested that you deploy PostgreSQL using persistent storage. More information on the containerized PostgreSQL deployment tested with this project is available [here](https://catalog.redhat.com/software/containers/rhel8/postgresql-10/5ba0ae0ddd19c70b45cbf4cd).

## Operator Deployment

A Gitea Operator can be found [here](https://github.com/RedHatGov/gitea-operator). Operators are the preferred way to deploy applications on Kubernetes.
