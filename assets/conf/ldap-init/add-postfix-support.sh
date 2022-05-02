#!/bin/bash

ldapadd -x -H ldap:/// -D cn=admin,cn=config -w adminopenpaas -f /linagora/ldifs/postfix.ldif

# ldapmodify -x -H ldap:/// -D cn=admin,dc=openpaas,dc=org -w adminopenpaas -f /linagora/ldifs/modify-postfix-user.ldif
