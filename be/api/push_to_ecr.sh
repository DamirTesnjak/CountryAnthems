#!/bin/bash
set -euo pipefail

# log in
aws ecr get-login-password --region "$REGION" \
  | docker login --username AWS --password-stdin "$REPO_URL"

# build, tag, push
docker build -t "${NAME}:${IMAGE_TAG}" .
docker tag "${NAME}:${IMAGE_TAG}" "${REPO_URL}:${IMAGE_TAG}"
docker push "${REPO_URL}:${IMAGE_TAG}"