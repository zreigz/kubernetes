#!/bin/bash

# Copyright 2015 The Kubernetes Authors All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# A library of helper functions that each provider hosting Kubernetes must implement to use cluster/kube-*.sh scripts.

# exit on any error
set -e

# Use the config file specified in $KUBE_CONFIG_FILE, or default to
# config-default.sh.
KUBE_ROOT=$(dirname "${BASH_SOURCE}")/../..
readonly ROOT=$(dirname "${BASH_SOURCE}")
source "${ROOT}/${KUBE_CONFIG_FILE:-"config-default.sh"}"
source "${ROOT}/openrc-default.sh"
source "$KUBE_ROOT/cluster/common.sh"

# Verify prereqs on host machine
function verify-prereqs() {
 # Check the OpenStack command-line clients
 for client in swift glance nova heat;
 do
  if which $client >/dev/null 2>&1; then
    echo "$client client installed"
  else
    echo "$client client does not exist"
    echo "Please install $client client, and retry."
    exit 1
  fi
 done
}

# Instantiate a kubernetes cluster
function kube-up() {
    echo "kube-up for provider $KUBERNETES_PROVIDER"
    get-resources
    create-stack
}

function validate-cluster() {
   echo "validate-cluster for $KUBERNETES_PROVIDER"
}


# Prepere all data for deployment
#
# Assumed vars:
#   OPENSTACK
#   OPENSTACK_TEMP
function get-resources() {
  echo "[INFO] Copy all resources to host"
  ensure-setup-dir
  curl -L ${IMAGE_URL} -o ${OPENSTACK_TEMP}/${IMAGE_NAME}
}

# Create stack
#
# Assumed vars:
#   OPENSTACK
#   OPENSTACK_TEMP
#   DNS_SERVER
#   OPENSTACK_IP
#   OPENRC_FILE
function create-stack() {
  echo "[INFO] Execute commands to create Kubernetes cluster"
  create-glance-image
  upload-resources
  add-keypair
  run-heat-script
}

# Upload kubernetes release tars and heat templates.
#
# Assumed vars:
#   ROOT
#   KUBERNETES_RELEASE_TAR
function upload-resources() {
  swift post kubernetes --read-acl '.r:*,.rlistings'

  echo "[INFO] Upload ${KUBERNETES_RELEASE_TAR}"
  swift upload kubernetes ${ROOT}/../../_output/release-tars/${KUBERNETES_RELEASE_TAR} \
    --object-name kubernetes-server.tar.gz

  echo "[INFO] Upload kubernetes-salt.tar.gz"
  swift upload kubernetes ${ROOT}/../../_output/release-tars/kubernetes-salt.tar.gz \
    --object-name kubernetes-salt.tar.gz

  echo "[INFO] Upload heat templates"
  swift upload kubernetes ${ROOT}/kubernetes-heat/kubeminion.yaml \
    --object-name kubeminion.yaml
  swift upload kubernetes ${ROOT}/kubernetes-heat/fragments/kube-user.yaml \
    --object-name kube-user.yaml
  swift upload kubernetes ${ROOT}/kubernetes-heat/fragments/write-heat-params.yaml \
    --object-name write-heat-params.yaml
  swift upload kubernetes ${ROOT}/kubernetes-heat/fragments/provision-network-node.sh \
    --object-name provision-network-node.sh
  swift upload kubernetes ${ROOT}/kubernetes-heat/fragments/deploy-kube-auth-files-node.yaml \
    --object-name deploy-kube-auth-files-node.yaml
  swift upload kubernetes ${ROOT}/kubernetes-heat/fragments/configure-salt.yaml \
    --object-name configure-salt.yaml
  swift upload kubernetes ${ROOT}/kubernetes-heat/fragments/run-salt.sh \
    --object-name run-salt.sh
}

# Create a new key pair for use with servers.
#
# Assumed vars:
#   KUBERNETES_KEYPAIR_NAME
#   CLIENT_PUBLIC_KEY_PATH
function add-keypair() {
  local status=$(nova keypair-show ${KUBERNETES_KEYPAIR_NAME})
  if [[ ! $status ]]; then
    nova keypair-add ${KUBERNETES_KEYPAIR_NAME} --pub-key ${CLIENT_PUBLIC_KEY_PATH}
    echo "[INFO] Key pair created"
  else
    echo "[INFO] Key pair already exists"
  fi
}

# Create a new glance image.
#
# Assumed vars:
#   IMAGE_NAME
#   OPENSTACK_TEMP
function create-glance-image() {
  local image_status=$(glance image-show ${OPENSTACK_IMAGE_NAME} | awk '$2=="id" {print $4}')

  if [[ ! $image_status ]]; then
    echo "[INFO] Create image ${OPENSTACK_IMAGE_NAME}"
    glance image-create --name ${OPENSTACK_IMAGE_NAME} --disk-format ${IMAGE_FORMAT} \
      --container-format ${CONTAINER_FORMAT} --file ${OPENSTACK_TEMP}/${IMAGE_NAME}
  else
    echo "[INFO] Image ${OPENSTACK_IMAGE_NAME} already exists"
  fi
}

# Create a new kubernetes stack.
#
# Assumed vars:
#   IMAGE_NAME
#   STACK_NAME
#   KUBERNETES_KEYPAIR_NAME
#   DNS_SERVER
#   OPENSTACK_SERVER_IP
#...OS_TENANT_ID
function run-heat-script() {
  local image_id=$(glance image-show ${OPENSTACK_IMAGE_NAME} | awk '$2=="id" {print $4}')
  local stack_status=$(heat stack-show ${STACK_NAME})
  local swift_repo_url="http://${OPENSTACK_SERVER_IP}:8080/v1/AUTH_${OS_TENANT_ID}/kubernetes"

  if [[ ! $stack_status ]]; then
    echo "[INFO] Create stack ${STACK_NAME}"
    heat --timeout 60 stack-create \
    -P external_network=public \
    -P ssh_key_name=${KUBERNETES_KEYPAIR_NAME} \
    -P server_image=$image_id \
    -P master_flavor=m1.small \
    -P minion_flavor=m1.small \
    -P number_of_minions=${NUMBER_OF_MINIONS} \
    -P max_number_of_minions=${MAX_NUMBER_OF_MINIONS} \
    -P dns_nameserver=${DNS_SERVER} \
    -P kubernetes_salt_url=$swift_repo_url/kubernetes-salt.tar.gz \
    -P kubernetes_server_url=$swift_repo_url/kubernetes-server.tar.gz \
    -P kubeminion_yaml_url=$swift_repo_url/kubeminion.yaml \
    -P kube_user_yaml_url=$swift_repo_url/kube-user.yaml \
    -P provision_network_node_sh_url=$swift_repo_url/provision-network-node.sh \
    -P write_heat_params_yaml_url=$swift_repo_url/write-heat-params.yaml \
    -P deploy_kube_auth_files_node_yaml_url=$swift_repo_url/deploy-kube-auth-files-node.yaml \
    -P configure_salt_yaml_url=$swift_repo_url/configure-salt.yaml \
    -P run_salt_sh_url=$swift_repo_url/kubernetes/run-salt.sh \
    --template-file ${ROOT}/kubernetes-heat/kubecluster.yaml \
    ${STACK_NAME}
  else
    echo "[INFO] Stack ${STACK_NAME} already exists"
    heat stack-show ${STACK_NAME}
  fi
}

# Create dirs that'll be used during setup on client machine.
#
# Assumed vars:
#   OPENSTACK_TEMP
function ensure-setup-dir() {
  mkdir -p ${OPENSTACK_TEMP}
}
