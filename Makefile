# Name of your project
PROJECT_NAME := boxartbuddy
VERSION := $(shell git describe --tags --exact-match 2>/dev/null || echo 1.1.1)
DIST_NAME := $(PROJECT_NAME)-$(VERSION)
CONTENT_DIR := BoxartBuddy
DIST_DIR := dist
ZIP_FILE := $(DIST_DIR)/$(DIST_NAME).muxapp
DISTIGNORE := .distignore
DEVICE_IP := 192.168.1.45

.PHONY: dist clean deploy

dist:
	@echo "Creating distribution..."
	@rm -rf $(DIST_DIR)
	@mkdir -p $(DIST_DIR)
	@rsync -a . $(DIST_DIR)/$(CONTENT_DIR) \
		--exclude-from=$(DISTIGNORE) \
		--exclude=$(DIST_DIR) \
		--delete-excluded
	@mkdir -p $(DIST_DIR)/glyph/muxapp
	@cp ./boxart-buddy/assets/image/glyph.png $(DIST_DIR)/glyph/muxapp/boxartbuddy.png
	@cd $(DIST_DIR) && zip -r $(DIST_NAME).muxapp .
	@rm -rf $(DIST_DIR)/$(CONTENT_DIR) $(DIST_DIR)/glyph
	@echo "Created $(ZIP_FILE)"

clean:
	rm -rf $(DIST_DIR)

deploy:
	@sshpass -p 'root' scp $(ZIP_FILE) root@$(DEVICE_IP):/mnt/mmc/ARCHIVE
	@echo "Deployed to $(DEVICE_IP):/mnt/mmc/ARCHIVE"

all: clean dist