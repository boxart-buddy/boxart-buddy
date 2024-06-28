bootstrap: ## Bootstrap to create config files on initial setup (run this 1st)
	php bin/console bootstrap
bootstrap-tinybest: ##
	php bin/console bootstrap --preset=TINYBEST
bootstrap-done2: ##
	php bin/console bootstrap --preset=DONE2
scrape: ## Scrape screenscraper and fill the cache prior to generation (run this 2nd)
	php bin/console scrape
build: ## Build artwork (run this 3rd)
	php bin/console build-interactive
scrape-skipped: ## Import skipped roms from the 'missing.json' file
	php bin/console import-skipped
build-all: ## Builds every combination of template/variant with default options
	php bin/console build-all
new-template:  ## Creates a new template folder, ready for editing
	php bin/console new-template
help:
	@egrep -h '\s##\s' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m  %-70s\033[0m %s\n", $$1, $$2}'

.PHONY: bootstrap
.PHONY: bootstrap-tinybest
.PHONY: bootstrap-done2
.PHONY: scrape
.PHONY: scrape-skipped
.PHONY: build
.PHONY: help
.DEFAULT_GOAL := help
