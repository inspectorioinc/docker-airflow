#!/usr/bin/env bash

set -euxo pipefail

: "${POSTGRES_HOST:="postgres"}"
: "${POSTGRES_PORT:="5432"}"
: "${POSTGRES_USER:="airflow"}"
: "${POSTGRES_PASSWORD:="airflow"}"
: "${POSTGRES_DB:="airflow"}"

: "${AIRFLOW__CORE__FERNET_KEY:=${FERNET_KEY:=$(python -c "from cryptography.fernet import Fernet; FERNET_KEY = Fernet.generate_key().decode(); print(FERNET_KEY)")}}"
: "${AIRFLOW__CORE__EXECUTOR:=${EXECUTOR:-Local}Executor}"

export \
  AIRFLOW__CORE__EXECUTOR \
  AIRFLOW__CORE__FERNET_KEY

export AIRFLOW__CORE__SQL_ALCHEMY_CONN=${AIRFLOW__CORE__SQL_ALCHEMY_CONN:-postgresql+psycopg2://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST:$POSTGRES_PORT/$POSTGRES_DB}
export AIRFLOW__CORE__LOAD_EXAMPLES="False"

# Install custom python package if requirements.txt is present
if [ -e "${AIRFLOW_HOME}/dags/airflow-dags/requirements.txt" ]; then
    pip install -r "${AIRFLOW_HOME}/dags/airflow-dags/requirements.txt"
fi

### init airflow db
runuser app -p -c 'airflow initdb'

### reconfigure supervisor conf
envsubst < /etc/supervisor/conf.d/webserver.conf | sponge /etc/supervisor/conf.d/webserver.conf
envsubst < /etc/supervisor/conf.d/scheduler.conf | sponge /etc/supervisor/conf.d/scheduler.conf

### supervisor as PID 1
exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
