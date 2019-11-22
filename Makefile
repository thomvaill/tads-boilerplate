#:## Help
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help
	@awk 'BEGIN { \
		print "T.A.D.S. Makefile";\
	\
		FS = ":.*?## "} \
	/^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2} \
	/^#:## / {printf "\n\033[35m%s\033[0m\n", $$2} ' \
	$(MAKEFILE_LIST)

.DEFAULT_GOAL := help

#:## Lint tasks
lint: lint-scripts lint-terraform lint-ansible ## Execute all lint tasks

lint-scripts: ## Perform a shellcheck linting on all scripts
	shellcheck tads scripts/**/*.sh

lint-terraform: ## Perform a "terraform validate" linting
	./tads terraform production validate

lint-ansible: ## Perform an ansible-lint linting
	ansible-lint ansible/*.yml

#:## Test tasks
test: test-scripts test-ansible-roles test-ansible-e2e ## Execute all test tasks

test-scripts: ## Run scripts integration tests
	./scripts/tests/launcher.sh

test-scripts-watch: ## Run scripts integration tests in watch mode
	./scripts/tests/watch.sh

test-ansible-roles: ## Test each Ansible role
	for d in ansible/roles/*; do (cd $${d} && molecule test); done

test-ansible-e2e: ## End-to-End Ansible test
	cd ansible && molecule test
