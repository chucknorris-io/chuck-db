.PHONY: default
default: help;

STACK_SLUG := chucknorris/postgres

help:                ## Show this help
	@echo '----------------------------------------------------------------------'
	@echo $(STACK_SLUG)
	@echo '----------------------------------------------------------------------'
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'
	@echo '----------------------------------------------------------------------'

build:               ## Build the container
	@docker build \
		--file Dockerfile \
		--tag "${STACK_SLUG}:latest" .

connect:             ## Start an interactive psql session
	@docker exec -it "chucknorris-postgres" psql chuck -h localhost -U postgres

destroy:             ## Delete the image
	@docker rmi "${STACK_SLUG}"

run:                 ## Run the container
	@docker run -d \
		-p '5432:5432' \
		--name "chucknorris-postgres" \
		"${STACK_SLUG}:latest"

stop:                ## Stop and remove the container
	@docker kill "chucknorris-postgres"
	@docker rm "chucknorris-postgres"
