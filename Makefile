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

GIT_BRANCH = $(shell git rev-parse --abbrev-ref HEAD)
GIT_TAG = $(shell git describe --always --tags --abbrev=0 | tr -d 'v')
GIT_COMMIT = $(shell git rev-parse HEAD)

all: envcheck restore gitwarden-agent ## Build everything

gitwarden-agent: ## Generate a build for each target
	$(eval LINKER_FLAGS = -X main.version=$(GIT_TAG) -X main.branch=$(GIT_BRANCH) -X main.commit=$(GIT_COMMIT))
ifeq ($(static), true)
	$(eval COMPILE_PREPEND = CGO_ENABLED=0 )
	$(eval COMPILE_PARAMS = -ldflags "-s $(LINKER_FLAGS)" -a -installsuffix cgo )
else
	$(eval COMPILE_PARAMS = -ldflags "$(LINKER_FLAGS)" )
endif
	@echo "Building '$@'"
	$(COMPILE_PREPEND)go build $(COMPILE_PARAMS)./cmd/$@

release: cleanroom ## Tag and generate a release build (example: make release version=1.2.3)

envcheck: ## Check environment for any common issues
ifneq ($(shell which go &>/dev/null; echo $$?),0)
	$(error "Go not installed.")
endif

cleanroom: ## Create a 'clean room' build
ifneq ($(shell git diff-files --quiet --ignore-submodules -- ; echo $$?), 0)
	$(error "Uncommitted changes in the current directory.")
endif
	$(eval CURR_DIR = $(shell pwd))
	$(eval TEMP_DIR = $(shell mktemp -d))
	mkdir -p $(TEMP_DIR)/src/github.com/gitwarden/gitwarden-agent
	cp -r . $(TEMP_DIR)/src/github.com/gitwarden/gitwarden-agent
	cd $(TEMP_DIR)/src/github.com/gitwarden/gitwarden-agent
	GOPATH="$(TEMP_DIR)" make all
	cd $(CURR_DIR)
	cp $(TEMP_DIR)/bin/* .

docker-build: clean ## Create a build in Docker
	./scripts/docker-image.sh
	./scripts/docker-build.sh

docker-package: docker-build ## Generate packages in Docker
	./scripts/docker-package.sh

package: ## Generate packages
	./scripts/package.sh

get: ## Retrieve Go dependencies
	PATH=$$PATH:$$GOPATH/bin dep ensure

get-update: ## Retrieve updated Go dependencies
	PATH=$$PATH:$$GOPATH/bin dep ensure-update

clean: ## Remove existing binaries
	@for target in gitwarden-agent; do \
		rm -f $$target ; \
	done

help: ## Display usage information
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-31s\033[0m %s\n", $$1, $$2}'

.PHONY: help,cleanroom,envcheck,restore,docker-build,docker-package
.DEFAULT_GOAL := help
