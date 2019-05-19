.PHONY: default
default: help;

STACK_SLUG := chucknorrisio/postgres
STACK_VERSION := 9.6.13

help:                ## Show this help
	@echo '----------------------------------------------------------------------'
	@echo $(STACK_SLUG)
	@echo '----------------------------------------------------------------------'
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'
	@echo '----------------------------------------------------------------------'

build:               ## Build the container
	@docker build \
		--file Dockerfile \
		--tag "${STACK_SLUG}:${STACK_VERSION}" .

connect:             ## Start an interactive psql session
	@docker exec -it "chucknorris-postgres" psql chuck -h localhost -U postgres

destroy:             ## Delete the image
	@docker rmi "${STACK_SLUG}"

release:             ## Push image to docker registry
	@docker push "${STACK_SLUG}:${STACK_VERSION}"

run:                 ## Run the container
	@docker run -d \
		-p '5432:5432' \
		--name "chucknorris-postgres" \
		"${STACK_SLUG}:${STACK_VERSION}"

stop:                ## Stop and remove the container
	@docker kill "chucknorris-postgres"
	@docker rm "chucknorris-postgres"
