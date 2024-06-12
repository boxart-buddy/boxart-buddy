include template/*/Makefile

help:
	@egrep -h '\s##\s' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m  %-60s\033[0m %s\n", $$1, $$2}'

.PHONY: help
.DEFAULT_GOAL := help
