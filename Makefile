.PHONY: all build release latest
ifndef VERBOSE
.SILENT:
endif

ifeq (build,$(firstword $(MAKECMDGOALS)))
  RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
endif

ifeq (release,$(firstword $(MAKECMDGOALS)))
  RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
endif

ifeq (latest,$(firstword $(MAKECMDGOALS)))
  RUN_ARGS := $(wordlist 1,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
endif

default:
	@echo "Usage:"
	@echo "make build [latest]           | build image as 'latest' or with version tag"
	@echo "make release                  | build image and release version"

build:
	scripts/build.sh $(RUN_ARGS)

latest: build

release:
	scripts/check_version.sh $(RUN_ARGS)
	scripts/build.sh $(RUN_ARGS)
	scripts/release.sh $(RUN_ARGS)
