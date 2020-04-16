#!/bin/bash
set -e

# Add local env variables from esn-init-config configmap
export NO_REPLY_ADDRESS_ESN=noreply@open-paas.org

export URL_ESN=http://backend.smartsla.local
export SMTP_SERVER_HOST=${JAMES_SERVER_HOST:-james}
export SMTP_SERVER_PORT=${JAMES_SERVER_PORT:-25}
export LDAP_CONNECTION_URI=${LDAP_CONNECTION_URI:-ldap://ldap:389}

export ESN_PLATFORMADMIN_DEFAULT_PASSWORD=secret

echo "INFO:waiting ESN to be up and running..."
wait-for-it.sh $ESN_HOST:$ESN_PORT -s

echo "INFO:begin esn init"
esncli.py password --new-password "${ESN_CLI_PASSWORD}";
esncli.py core-login --nb_retry 5
esncli.py core-features
esncli.py core-email --no-reply-email "${NO_REPLY_ADDRESS_ESN}" \
    --feedback-email "feedback@open-paas.org" \
    --server-host "${SMTP_SERVER_HOST}" \
    --server-port "${SMTP_SERVER_PORT}";
esncli.py core-web --frontend-url "${URL_ESN}";
esncli.py general --time-format-24
esncli.py core-ldap --uri "${LDAP_CONNECTION_URI}" \
    --name "LDAP Openpaas" \
    --bind-dn "${OPENPAAS_BIND_DN}" \
    --bind-password "${OPENPAAS_BIND_PW}" \
    --search-base "${LDAP_SEARCH_BASE}" \
    --usage-auth --usage-search --usage-provisioning;
echo "INFO:esn init completed"
