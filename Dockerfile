FROM inspectorio/python:3.6
LABEL maintainer="Inspectorio DevOps <devops@inspectorio.com>"

ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux

# Airflow
ARG AIRFLOW_VERSION=1.10.2
ARG AIRFLOW_DEPS=""
ARG PYTHON_DEPS=""
ENV AIRFLOW_HOME=/usr/local/airflow
ENV AIRFLOW_GPL_UNIDECODE yes

# Define en_US
ENV LANGUAGE C.UTF-8
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV LC_CTYPE C.UTF-8
ENV LC_MESSAGES C.UTF-8

COPY config/airflow.cfg ${AIRFLOW_HOME}/airflow.cfg

# hadolint ignore=DL3013
RUN pip install apache-airflow[crypto,jdbc,kubernetes,postgres,s3,slack,sendgrid,ssh${AIRFLOW_DEPS:+,}${AIRFLOW_DEPS}]==${AIRFLOW_VERSION} \
&&  if [ -n "${PYTHON_DEPS}" ]; then pip install ${PYTHON_DEPS}; fi \
&&  chown -R "${APP_USER}":"${APP_GRP}" "${AIRFLOW_HOME}"

EXPOSE 8080 5555 8793

WORKDIR ${AIRFLOW_HOME}
