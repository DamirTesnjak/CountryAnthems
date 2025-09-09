#!/bin/bash
set -euo pipefail

region="$1"
repo_url="$2"
name="$3"
image_tag="$4"

# log in
aws ecr get-login-password --region "$region" \
  | docker login --username AWS --password-stdin "$repo_url"

# build, tag, push
docker build -t "$name-api:$image_tag" .
docker tag "$name-api:$image_tag" "$repo_url/$name-api:$image_tag"
docker push "$repo_url/$name-api:$image_tag"