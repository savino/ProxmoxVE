#!/usr/bin/env bash

# Copyright (c) 2021-2026 community-scripts ORG
# Author: [YourGitHubUsername]
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://docs.anythingllm.com/

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Docker"
$STD sh <(curl -fsSL https://get.docker.com)
msg_ok "Installed Docker"

msg_info "Creating AnythingLLM directories"
mkdir -p /appdata/anythingllm
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

msg_info "Waiting for AnythingLLM to start (30 seconds)"
sleep 30
msg_ok "AnythingLLM should now be accessible"

motd_ssh
customize
cleanup_lxc
