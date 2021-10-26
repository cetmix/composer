#!/bin/bash

ACTION=${1:-"up -d"}

source ./.env

export GID=$(id -g)

if [ ! -d ${ODOO_DATA} ]; then
  echo "Create ${ODOO_DATA} folder"
  mkdir -p ${ODOO_DATA}
fi

if [ "${ACTION}" != "down" ]; then

  #create folders
  for dir in config extra-addons; do
    echo "Create ${ODOO_DATA}/${dir} folder"
    mkdir -p ${ODOO_DATA}/${dir}
  done

  #copy config
  echo "Copy odoo config"
  cp ./configs/odoo.conf ${ODOO_DATA}/config/
  
  #clone code
  echo "Clone cetmix-tools repo"
  git clone --quiet -b ${ODOO_CODE_BRANCH:-fb-11-pipe} git@github.com:cetmix/cetmix-tools.git ./code
  echo "Clone docker repo"
  git clone --quiet -b ${DOCKER_CODE_BRANCH:-master} git@github.com:cetmix/docker.git ./docker

  echo "Get list of addons"
  export ODOO_INIT_ARGS="-i $(bash ./docker/scripts/addons_list.sh | tr ' ' ',')"

  # start postgres and odoo-init
  docker-compose -f ./docker-compose-init.yml ${ACTION}

  #waiting for odoo init
  echo Waiting for odoo init
  exit_code="$(docker wait odoo-init-${ODOO_TAG:-fb-11-pipe})"
fi

if [[ "${exit_code}" != "0" && "${ACTION}" != "down" ]]; then
  echo "Odoo init failed"
  exit 1
fi

#check exist status code of odoo init
if [[ "${exit_code}" == "0" || "${ACTION}" == "down" ]]; then
  docker-compose -f ./docker-compose-odoo.yml ${ACTION}
fi

#Print odoo URL
if [[ "${ACTION}" != "down" && "${exit_code}" == "0" ]]; then
  port=$(docker inspect odoo-${ODOO_TAG:-fb-11-pipe} --format '{{(index (index .NetworkSettings.Ports "8069/tcp") 0).HostPort}}')
  echo "URL = http://127.0.0.1:${port}"
fi

# start postgres and odoo-init
if [ "${ACTION}" == "down" ]; then
  docker-compose -f ./docker-compose-init.yml ${ACTION} -v
fi

if [ "${ACTION}" == "down" ]; then
  echo "Remove data folders"
  rm -rf ${ODOO_DATA}/*
  rm -rf ./docker
  rm -rf ./code
fi
