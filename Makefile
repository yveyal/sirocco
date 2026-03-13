EXAMPLE_SITE ?= exampleSite
THEME_NAME ?= .
THEMES_DIR ?= ..
DIST_DIR ?= dist
HUGO_IMAGE ?= klakegg/hugo:ext-alpine
DOCKER_MOUNT ?= $(CURDIR):/src
DOCKER_WORKDIR ?= /src
DOCKER_USER ?= $(shell id -u):$(shell id -g)

DOCKER_RUN = docker run --rm --user $(DOCKER_USER) -v $(DOCKER_MOUNT) -w $(DOCKER_WORKDIR)
HUGO_RUN = $(DOCKER_RUN) $(HUGO_IMAGE)
HUGO_RUN_DEV = $(DOCKER_RUN) -p 1313:1313 $(HUGO_IMAGE)

.PHONY: dev build clean

dev:
	$(HUGO_RUN_DEV) server --source $(EXAMPLE_SITE) --theme $(THEME_NAME) --themesDir $(THEMES_DIR) --bind 0.0.0.0 --port 1313 --disableFastRender

build:
	$(HUGO_RUN) --source $(EXAMPLE_SITE) --theme $(THEME_NAME) --themesDir $(THEMES_DIR) --destination ../$(DIST_DIR)

clean:
	rm -rf $(DIST_DIR) $(EXAMPLE_SITE)/public $(EXAMPLE_SITE)/resources $(EXAMPLE_SITE)/.hugo_build.lock
