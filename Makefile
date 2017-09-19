.PHONY: help init clone
.DEFAULT: help
ifndef VERBOSE
.SILENT:
endif
SHELL=bash
CWD=$(shell pwd -P)
BOX=dev
DONE=@printf "$(OK_COLOUR)✓ $@ done$(NO_COLOUR)\n\n"
FAIL=@printf "$(ERROR_COLOUR)✓ $@ fail$(NO_COLOUR)\n\n"

#Colours
NO_COLOUR=\033[0m
OK_COLOUR=\033[32m
INFO_COLOUR=\033[33m
ERROR_COLOUR=\033[31;01m
WARN_COLOUR=\033[33;01m

ifeq ($(shell whoami),vagrant)
	REL_PATH=/srv
	SRV_ENV=vagrant
else
    REL_PATH=$(CWD)
    SRV_ENV=host
endif

# Define the package type
ifndef ($(package))
	package=dev
else
	package=prod
endif

#Define repository names
WEB_APP=interview.io

# Set project paths
ROOT_PATH=$(REL_PATH)
WEB_APP_PATH=$(ROOT_PATH)/../$(WEB_APP)

help::
	@printf "Project targets\n"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "$(INFO_COLOUR)%-35s$(NO_COLOUR) %s\n", $$1, $$2}'
	@printf "\n"

init: clone build ## Init Web App
	$(DONE)

##########################
##### Common targets #####
##########################

local-build: ## Build Web App without docker for local machine testing
	@printf "\n$(INFO_COLOUR)Building project$(NO_COLOUR)\n"
	$(MAKE) -C $(ROOT_PATH)/../interview.io/ init
	$(DONE)

clone: ## Cloning project repositories
	@printf "\n$(INFO_COLOUR)Cloning web app$(NO_COLOUR)\n"
	cd $(WEB_APP_PATH); git clone git@github.com:evgeniyannenkov/$(WEB_APP).git
	$(DONE)

build: ## Build Docker infrastructure and start application inside container
	@printf "\n$(INFO_COLOUR)Starting application$(NO_COLOUR)\n"
	cd $(ROOT_PATH); docker-compose up -d
	$(DONE)

rebuild: ## Stop and remove containers, networks, images, and volumes; create and start application inside container
	@printf "\n$(INFO_COLOUR)Rebuilding application$(NO_COLOUR)\n"
	cd $(ROOT_PATH); docker-compose down && docker-compose build && docker-compose up -d
	$(DONE)

destroy: ## Stop and remove containers, networks, images, and volumes
	@printf "\n$(INFO_COLOUR)Removing all Docker infrastructure$(NO_COLOUR)\n"
	cd $(ROOT_PATH); docker-compose down && docker stop $(docker ps -a -q) && docker rmi $(docker images -q)
	$(DONE)
