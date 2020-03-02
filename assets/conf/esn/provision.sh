#!/bin/bash
set -x
set -e

CURRENT_DOMAIN_ADMIN=admin@open-paas.org

echo 'Provisioning ESN configuration and data'
node ./bin/cli configure
node ./bin/cli elasticsearch --host $ELASTICSEARCH_HOST --port $ELASTICSEARCH_PORT
node ./bin/cli domain create --email ${CURRENT_DOMAIN_ADMIN} --password secret --ignore-configuration
node ./bin/cli platformadmin init --email "${CURRENT_DOMAIN_ADMIN}"
