#!/bin/bash

# List of databases currently available in the docker-compose instance.
export PGUSER='postgres'
export PGPASSWORD='postgres'
export PGHOST='expenses-db'

psql -qAtX -c 'SELECT datname FROM pg_database;'
