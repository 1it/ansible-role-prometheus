#!/bin/bash

init_user_sql() {
psql -v ON_ERROR_STOP=1 <<-EOSQL
CREATE USER $USER_NAME PASSWORD '$USER_PASSWD';
EOSQL
}

init_grafana_sql() {
psql -v ON_ERROR_STOP=1 <<-EOSQL
CREATE DATABASE grafana OWNER $USER_NAME TEMPLATE template0;
GRANT ALL PRIVILEGES ON DATABASE grafana TO $USER_NAME;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $USER_NAME;
EOSQL
}

# Create user and database
init_user_sql;
init_grafana_sql;
