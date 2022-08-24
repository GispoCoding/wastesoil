#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER $DB_USER with login password '$DB_PASSWORD';
    CREATE DATABASE $DB_NAME OWNER $DB_USER;
    GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;
    \connect $DB_NAME;
    CREATE EXTENSION postgis;
EOSQL
