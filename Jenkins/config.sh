#!/bin/bash

# Jenkins URL та креденціали
JENKINS_URL="http://51.21.134.100:8080"
JENKINS_USER="admin"
JENKINS_PASSWORD="****"

# SSH-ключі та GitHub
GITHUB_TOKEN=""
SSH_KEY_PATH="/root/.ssh/id_ed25519"
GITHUB_EMAIL="*************@gmail.com"
CREDENTIAL_ID="ssh-key-jenkins"

# Docker Hub
DOCKERHUB_USER="sasha22mk"
DOCKERHUB_PASSWORD=""

# S3
BUCKET_NAME="beckup-site"
AWS_ACCESS_KEY_ID=""
AWS_SECRET_ACCESS_KEY=""
AWS_REGION="eu-north-1"

# Jenkins файли
CLI_JAR="jenkins_files/jenkins-cli.jar"
JOB_DIR="jenkins_jobs"
