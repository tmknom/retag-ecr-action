# This option causes make to display a warning whenever an undefined variable is expanded.
MAKEFLAGS += --warn-undefined-variables

# Disable any builtin pattern rules, then speedup a bit.
MAKEFLAGS += --no-builtin-rules

# If this variable is not set, the program /bin/sh is used as the shell.
SHELL := /bin/bash

# The arguments passed to the shell are taken from the variable .SHELLFLAGS.
#
# The -e flag causes bash with qualifications to exit immediately if a command it executes fails.
# The -u flag causes bash to exit with an error message if a variable is accessed without being defined.
# The -o pipefail option causes bash to exit if any of the commands in a pipeline fail.
# The -c flag is in the default value of .SHELLFLAGS and we must preserve it.
# Because it is how make passes the script to be executed to bash.
.SHELLFLAGS := -eu -o pipefail -c

# Disable any builtin suffix rules, then speedup a bit.
.SUFFIXES:

# Sets the default goal to be used if no targets were specified on the command line.
.DEFAULT_GOAL := help

#
# Variables for the directory path
#
CLI_CONFIG_DIR ?= .github

#
# Variables to be used by docker commands
#
DOCKER ?= $(shell which docker)
DOCKER_RUN ?= $(DOCKER) run -i --rm -v $(CURDIR):/work -w /work

#
# Tests
#
.PHONY: test
test: test-yaml test-markdown ## test all

.PHONY: test-yaml
test-yaml: ## test yaml by yamllint and prettier
	$(DOCKER_RUN) yamllint --strict --config-file $(CLI_CONFIG_DIR)/.yamllint.yml .
	$(DOCKER_RUN) prettier --check --parser=yaml **/*.y*ml

.PHONY: test-markdown
test-markdown: ## test markdown by markdownlint, remark and prettier
	$(DOCKER_RUN) markdownlint --dot --config $(CLI_CONFIG_DIR)/.markdownlint.yml **/*.md
	$(DOCKER_RUN) remark --silently-ignore **/*.md
	$(DOCKER_RUN) prettier --check --parser=markdown **/*.md

#
# Format code
#
.PHONY: format
format: format-markdown format-yaml ## format all

.PHONY: format-markdown
format-markdown: ## format markdown by prettier
	$(DOCKER_RUN) prettier --write --parser=markdown **/*.md

.PHONY: format-yaml
format-yaml: ## format yaml by prettier
	$(DOCKER_RUN) prettier --write --parser=yaml **/*.y*ml

#
# Documentation management
#
.PHONY: docs
docs: ## update documents
	version=$$(cat VERSION) && \
	awk -v version=$${version} \
	    '{sub(/[0-9]+\.[0-9]+\.[0-9]+/, version, $$0); print $$0}' \
	    README.md > $${TMPDIR}/README.md && \
	mv $${TMPDIR}/README.md README.md

#
# Release management
#
release: push-tag create-release ## release

push-tag:
	full_version="v$$(cat VERSION)" && \
	major_version=$$(echo "$${full_version%%.*}") && \
	git tag --force "$${full_version}" && \
	git tag --force "$${major_version}" && \
	git push --force origin "$${full_version}" && \
	git push --force origin "$${major_version}"

create-release:
	full_version="v$$(cat VERSION)" && \
	notes="- Release $${full_version}" && \
	gh release create "$${full_version}" --notes "$${notes}" --draft && \
	echo "Wait GitHub Release creation..." && \
	sleep 3 && \
	gh release view "$${full_version}" --web

bump: input-version docs commit create-pr ## bump version

input-version:
	@echo "Current version: $$(cat VERSION)" && \
	read -rp "Input next version: " version && \
	echo "$${version}" > VERSION

commit:
	version=$$(cat VERSION) && \
	git switch -c "bump-$${version}" && \
	git add VERSION && \
	git commit -m "Bump up to $${version}" && \
	git add README.md && \
	git commit -m "Update docs to $${version}"

create-pr:
	git push origin $$(git rev-parse --abbrev-ref HEAD) && \
	gh pr create --fill --web

#
# Help
#
.PHONY: help
help: ## show help
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
