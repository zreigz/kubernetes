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

OPENSTACK_SERVER_IP="192.168.123.100"

# Directory to be used for openstack to store all resources.
OPENSTACK_TEMP="/home/lukasz/openstack_temp"

CLIENT_PUBLIC_KEY_PATH="~/.ssh/id_rsa.pub"

# Image name which will be displayed in OpenStack
OPENSTACK_IMAGE_NAME="UbuntuVivid"

# Downloaded image name for Openstack project
IMAGE_NAME="vivid-server-cloudimg-amd64-disk1.img"

# URL for image where Kubernetes will be installed
IMAGE_URL="http://uec-images.ubuntu.com/vivid/current/${IMAGE_NAME}"

# The disk format of the image. Acceptable formats are ami, ari, aki, vhd, vmdk, raw, qcow2, vdi, and iso.
IMAGE_FORMAT="qcow2"

# The container format of the image. Acceptable formats are ami, ari, aki, bare, docker, and ovf.
CONTAINER_FORMAT="bare"

# DNS server address
DNS_SERVER=10.182.64.138

# Stack name
STACK_NAME="KubernetesStack"

# Keypair for kubernetes stack
KUBERNETES_KEYPAIR_NAME="kubernetes_keypair"

KUBERNETES_RELEASE_TAR="kubernetes-server-linux-amd64.tar.gz"

NUMBER_OF_MINIONS=1

MAX_NUMBER_OF_MINIONS=1
