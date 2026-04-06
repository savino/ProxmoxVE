#!/usr/bin/env bash

# Copyright (c) 2021-2026 community-scripts ORG
# Author: savino
# License: MIT | https://github.com/savino/ProxmoxVE/raw/main/LICENSE
# Source: https://docs.anythingllm.com/

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Docker"
setup_docker
msg_ok "Installed Docker"

msg_info "Creating AnythingLLM directories"
mkdir -p /appdata/anythingllm
chown -R 1000:1000 /appdata/anythingllm
chmod 775 /appdata/anythingllm
msg_ok "Created directories"

msg_info "Creating AnythingLLM .env file"
cat <<EOF >/appdata/anythingllm/.env
# AnythingLLM Environment Configuration
# Storage directory is automatically set via -e STORAGE_DIR
STORAGE_DIR=/app/server/storage

# UID and GID for the AnythingLLM process
# Default is 1000, which matches the standard Docker user
# Change these if you have permission issues
UID=1000
GID=1000
EOF
msg_ok "Created .env file"

msg_info "Pulling AnythingLLM Docker image"
$STD docker pull mintplexlabs/anythingllm:latest
msg_ok "Pulled AnythingLLM image"

if docker ps -a --format '{{.Names}}' | grep -q '^anythingllm$'; then
  msg_info "Removing existing AnythingLLM container"
  $STD docker rm -f anythingllm
  msg_ok "Removed existing container"
fi

msg_info "Starting AnythingLLM container"
$STD docker run -d \
  --name anythingllm \
  --restart unless-stopped \
  -p 3001:3001 \
  --cap-add SYS_ADMIN \
  -v /appdata/anythingllm:/app/server/storage \
  -v /appdata/anythingllm/.env:/app/server/.env \
  -e STORAGE_DIR="/app/server/storage" \
  mintplexlabs/anythingllm:latest
msg_ok "Started AnythingLLM container"

msg_info "Validating AnythingLLM startup"
for _ in {1..30}; do
  if curl -fsS http://127.0.0.1:3001 >/dev/null 2>&1; then
    msg_ok "AnythingLLM is accessible on port 3001"
    break
  fi
  sleep 2
done

if ! curl -fsS http://127.0.0.1:3001 >/dev/null 2>&1; then
  msg_error "AnythingLLM did not become reachable on port 3001"
  docker logs --tail 200 anythingllm || true
  exit 1
fi

motd_ssh
customize
cleanup_lxc
