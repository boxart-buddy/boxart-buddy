include template/*/Makefile

bootstrap: ## Bootstrap to create config files on initial setup (run this 1st)
	php bin/console bootstrap
scrape: ## Scrape screenscraper and fill the cache prior to generation (run this 2nd)
	php bin/console scrape
help:
	@egrep -h '\s##\s' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m  %-70s\033[0m %s\n", $$1, $$2}'

.PHONY: help
.DEFAULT_GOAL := help
