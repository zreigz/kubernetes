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

## Contains configuration values for the Openstack cluster

# Stack name
STACK_NAME="KubernetesStack"

# Keypair for kubernetes stack
KUBERNETES_KEYPAIR_NAME="kubernetes_keypair"

# Kubernetes release tar file
KUBERNETES_RELEASE_TAR="kubernetes-server-linux-amd64.tar.gz"

NUMBER_OF_MINIONS="1"

MAX_NUMBER_OF_MINIONS="1"

MASTER_FLAVOR="1C-2GB" # "m1.small"

MINION_FLAVOR="1C-2GB" # "m1.small"

EXTERNAL_NETWORK="ext-net" # "public"

SWIFT_SERVER_URL="https://se.storage.citycloud.com" # "http://192.168.123.100:8080"

SWIFT_TENANT_ID="de27a88d218044339cff7851e70d50ea"

# Flag indicates if new image must be created. If 'false' then image with IMAGE_ID will be used.
# If 'true' then new image will be created from file config-image.sh
CREATE_IMAGE="false" # use "true" for devstack

# Image id which will be used for kubernetes stack
IMAGE_ID="f0f394b1-5546-4b68-b2bc-8abe8a7e6b8b"

# DNS server address
DNS_SERVER="91.123.193.111"

# Public RSA key path
CLIENT_PUBLIC_KEY_PATH="~/.ssh/id_rsa.pub"

# Max time period for stack provisioning. Time in minutes.
STACK_CREATE_TIMEOUT=60

KUBERNETES_CERT_PATH="/home/lukasz/openstack_temp"