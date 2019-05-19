FROM postgres:9.6.13-alpine

MAINTAINER Mathias Schilling <m@matchilling.com>

ENV POSTGRES_PASSWORD=postgres
ENV POSTGRES_USER=postgres
ENV POSTGRES_DB=chuck

COPY 'migration/0001/initial_setup_database_schema.sql' '/docker-entrypoint-initdb.d/01-initial_setup_database_schema.sql'
COPY 'migration/0002/initial_setup_stored_procedures.sql' '/docker-entrypoint-initdb.d/02-initial_setup_stored_procedures.sql'
COPY 'migration/0003/add_parental_control.sql' '/docker-entrypoint-initdb.d/03-add_parental_control.sql'
COPY 'data/example.sql' '/docker-entrypoint-initdb.d/04-example.sql'
