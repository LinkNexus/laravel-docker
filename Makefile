# Executables (local)
DOCKER_COMP = docker compose

# Docker containers
PHP_CONT = $(DOCKER_COMP) exec app

# Executables
PHP      = $(PHP_CONT) php
COMPOSER = $(PHP_CONT) composer
ARTISAN  = $(PHP) artisan

# Misc
.DEFAULT_GOAL = help
.PHONY        : help build up start down logs sh composer vendor artisan cc test

## —— 🎵 🐳 The Laravel Docker Makefile 🐳 🎵 ——————————————————————————————————
help: ## Outputs this help screen
	@grep -E '(^[a-zA-Z0-9\./_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

## —— Docker 🐳 ————————————————————————————————————————————————————————————————
build: ## Builds the Docker images
	@$(DOCKER_COMP) -f compose.yaml -f compose.override.yaml build --pull --no-cache

build-prod: ## Builds the Docker images for production
	@$(DOCKER_COMP) -f compose.yaml -f compose.prod.yaml build --pull --no-cache

run-app: ## Run the Docker containers
	@$(DOCKER_COMP) -f compose.yaml -f compose.override.yaml run app

up: ## Start the Docker containers in detached mode (no logs)
	@$(DOCKER_COMP) -f compose.yaml -f compose.override.yaml up --detach

up-prod: ## Start the Docker containers in detached mode for production (no logs)
	@$(DOCKER_COMP) -f compose.yaml -f compose.prod.yaml up --detach

start: build up ## Build and start the containers

down: ## Stop the Docker containers
	@$(DOCKER_COMP) down --remove-orphans

logs: ## Show live logs
	@$(DOCKER_COMP) logs --tail=0 --follow

sh: ## Connect to the FrankenPHP container
	@$(PHP_CONT) sh

## —— Composer 🧙 ——————————————————————————————————————————————————————————————
composer: ## Run composer, pass the parameter "c=" to run a given command, example: make composer c='req symfony/orm-pack'
	@$(eval c ?=)
	@$(COMPOSER) $(c)

vendor: ## Install vendors according to the current composer.lock file
vendor: c=install --prefer-dist --no-dev --no-progress --no-scripts --no-interaction
vendor: composer

## —— Laravel 🎵 ———————————————————————————————————————————————————————————————
artisan: ## List all Laravel Artisan commands or pass the parameter "c=" to run a given command, example: make artisan c=about
	@$(eval c ?=)
	@$(ARTISAN) $(c)

cc: c=cache:clear ## Clear the cache
cc: artisan