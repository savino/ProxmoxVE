#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2026 community-scripts ORG
# Author: [YourGitHubUsername]
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://docs.anythingllm.com/

APP="AnythingLLM"
var_tags="${var_tags:-docker;ai}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-2048}"
var_disk="${var_disk:-10}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"
var_keyctl="${var_keyctl:-1}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources

  if [[ ! -d /appdata/anythingllm ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi

  msg_info "Pulling latest ${APP} Docker image"
  $STD docker pull mintplexlabs/anythingllm:latest
  msg_ok "Pulled latest image"

  msg_info "Stopping ${APP} container"
  $STD docker stop anythingllm
  msg_ok "Stopped container"

  msg_info "Removing old ${APP} container"
  $STD docker rm anythingllm
  msg_ok "Removed container"

  msg_info "Starting new ${APP} container"
  $STD docker run -d \
    --name anythingllm \
    --restart unless-stopped \
    -p 3001:3001 \
    --cap-add SYS_ADMIN \
    -v /appdata/anythingllm:/app/server/storage \
    -v /appdata/anythingllm/.env:/app/server/.env \
    -e STORAGE_DIR="/app/server/storage" \
    mintplexlabs/anythingllm:latest
  msg_ok "Started container"

  msg_ok "Updated successfully!"
  exit
}

start
build_container
description

msg_ok "Completed successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:3001${CL}"
