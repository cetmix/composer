#!/bin/bash

ACTION=${1:-"up -d"}

source ./.env

if [ ! -d ${ODOO_DATA} ]; then
  mkdir -p ${ODOO_DATA}
fi

#create folders
for dir in config extra-addons; do
  mkdir -p ${ODOO_DATA}/${dir}
done

#copy config
cp ./configs/odoo.conf ${ODOO_DATA}/config/

#clone code
if [ "${ACTION}" != "down" ]; then
  git clone -b ${ODOO_CODE_BRANCH:-fb-11-pipe} git@github.com:cetmix/cetmix-tools.git ./code &> /dev/null
  git clone -b ${DOCKER_CODE_BRANCH:-master} git@github.com:cetmix/docker.git ./docker &> /dev/null
fi

export ODOO_INIT_ARGS="-i $(bash ./docker/scripts/addons_list.sh | tr ' ' ',')"

# start postgres and odoo-init
if [ "${ACTION}" != "down" ]; then
  docker-compose -f ./docker-compose-init.yml ${ACTION}
fi

if [ "${ACTION}" != "down" ]; then
  #waiting for odoo init
  echo Waiting for odoo init
  exit_code="$(docker wait odoo-init-${ODOO_TAG:-fb-11-pipe})"
fi

#check exist status code of odoo init
if [[ "${exit_code}" == "0" || "${ACTION}" == "down" ]]; then
  docker-compose -f ./docker-compose-odoo.yml ${ACTION}
fi

#Print odoo URL
if [ "${ACTION}" != "down" ]; then
  port=$(docker inspect odoo-${ODOO_TAG:-fb-11-pipe} --format '{{(index (index .NetworkSettings.Ports "8069/tcp") 0).HostPort}}')
  echo "URL = http://127.0.0.1:${port}"
fi

# start postgres and odoo-init
if [ "${ACTION}" == "down" ]; then
  docker-compose -f ./docker-compose-init.yml ${ACTION}
fi

if [ "${ACTION}" == "down" ]; then
  rm -rf ${ODOO_DATA:-~/cetmix/data}/*
  rm -rf ./docker
  rm -rf ./code
fi