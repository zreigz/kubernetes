#!/usr/bin/env bash

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

## Enviroment variables for the OpenStack Swift command-line client. This is required for CityCloud
## provider where Swift has different credentials. When Swift is part of your OpenStack use the same
## settings as in openrc-default.sh

export OS_AUTH_URL=https://identity.se.storage.citycloud.com/v2.0/
export OS_PROJECT_ID=de27a88d218044339cff7851e70d50ea
export OS_USERNAME=kubernetes-heat-swift
export OS_PASSWORD=kubernetes-heat-swift
export OS_REGION_NAME=RegionOne
