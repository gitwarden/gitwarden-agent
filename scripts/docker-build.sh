#!/bin/bash
#
# Author: Ross McDonald (ross.mcdonald@gitwarden.com)
# Copyright 2017, Summonry Labs
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
#
# For usage information, simply run `make` from the root directory of
# the gitwarden-agent repository.
#
# For bugs or feature requests, please file an issue against the GitWarden Agent
# repository on Github at:
#
# https://github.com/gitwarden/gitwarden-agent
#

set -e
docker run \
       --rm \
       -v $(pwd):/go/src/github.com/gitwarden/gitwarden-agent \
       gitwarden-agent:latest