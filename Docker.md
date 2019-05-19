# chucknorris.io database

Runs the Chuck Norris PostgreSQL database with some example data in a Docker container for local development.

## Getting Started

These instructions will cover usage information and for the docker container.

### Prerequisities

In order to run this container you'll need docker installed.

* [Windows](https://docs.docker.com/windows/started)
* [OS X](https://docs.docker.com/mac/started/)
* [Linux](https://docs.docker.com/linux/started/)

### Usage

```sh
# Run the latest version
$ docker run -p '5432:5432' --name chucknorris-database chucknorrisio/postgres

# Run a specific version (see https://hub.docker.com/r/chucknorrisio/postgres/tags)
$ docker run -p '5432:5432' --name chucknorris-database chucknorrisio/postgres:9.6.13

# Connect to the database
$ docker exec -it "chucknorris-database" psql chuck -h localhost -U postgres
```

## Find Us

* [GitHub](https://github.com/chucknorris-io/)

## License

This distribution is covered by the **GNU GENERAL PUBLIC LICENSE**, Version 3, 29 June 2007.

## Support & Contact

Having trouble with this repository? Check out the documentation at the repository's site or contact m@matchilling.com and we’ll help you sort it out.

Happy Coding

:v:
