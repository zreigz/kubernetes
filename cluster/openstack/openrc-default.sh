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

## Enviroment variables for the OpenStack command-line client

export CINDER_VERSION=2
export NOVA_VERSION=1.1
export OS_IDENTITY_API_VERSION=2.0
export OS_USERNAME=admin
export OS_PASSWORD=secretsecret
export OS_AUTH_URL=http://${OPENSTACK_SERVER_IP}:5000/v2.0
export OS_TENANT_NAME=admin
export OS_TENANT_ID=ac6d5b9646cf44a596a1c1c7e75f63dd
export OS_VOLUME_API_VERSION=2
export COMPUTE_API_VERSION=1.1
export OS_NO_CACHE=1
