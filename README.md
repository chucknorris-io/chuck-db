# chucknorris.io database repository

This repository contains the database schema, stored procedures and migration files for [chucknorris.io](https://api.chucknorris.io).

## Usage

* The `function/` directory contains always the latest version of the stored procedure.
* The `migration/` directory contains all migration files in the order of execution.
* The `schema/current.sql` file holds the latest version of the database schema.

### Docker

See [https://hub.docker.com/r/chucknorrisio/postgres](https://hub.docker.com/r/chucknorrisio/postgres).

```sh
# Run the latest version
$ docker run -p '5432:5432' --name chucknorris-database chucknorrisio/postgres

# Run a specific version (see https://hub.docker.com/r/chucknorrisio/postgres/tags)
$ docker run -p '5432:5432' --name chucknorris-database chucknorrisio/postgres:9.6.13
```

### Local build

```sh
# Build and run the container with the following make targets
$ make build
$ make run

# Stop and remove the container
$ make stop

# Start an interactive psql session
$ make connect

# Push image to docker registry
$ make release DOCKER_ACCOUNT=docker-account-name
```

## License

This distribution is covered by the **GNU GENERAL PUBLIC LICENSE**, Version 3, 29 June 2007.

## Support & Contact

Having trouble with this repository? Check out the documentation at the repository's site or contact m@matchilling.com and we’ll help you sort it out.

Happy Coding

:v:
