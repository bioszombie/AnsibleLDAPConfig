#!/bin/sh
# vim: set ts=4:
#
# This script finds and prints authorized SSH public keys in LDAP for the
# username specified as the first argument.
#
# The program must be owned by root and not writable by group or others.
# It expects configuration file /etc/ldap/ldap.conf in format of ldap.conf(5).
#
# sshd_config for OpenSSH 6.2+:
#
#   AuthorizedKeysCommand /usr/local/bin/ssh-keyldap
#   AuthorizedKeysCommandUser nobody
#
set -eu

LDAPCONF='/etc/ldap/ldap.conf'

log() {
        logger -s -t sshd -p "auth.$1" "$2"
}

uid="$1"
export LDAPCONF

if [ ! -r "$LDAPCONF" ]; then
        log err "file $LDAPCONF does not exist or not readable"
        exit 1
fi

if ! expr "$uid" : '[a-zA-Z0-9._-]*$' 1>/dev/null; then
        log err "bad characters in username: $uid"
        exit 2
fi

keys=$(ldapsearch \
-D bind_user_name \
-w bind_user_name_password \
-x -LLL \
-o ldif-wrap=no "(&(sAMAccountName=$uid)(sshPublicKey=*)(memberOf=cn=bind_user_name))" 'sshPublicKey' \
| sed -n 's/^sshPublicKey:\s*\(.*\)$/\1/p' \
| sed -n 's/map//p' \
| sed -n 's/:<nil>//p' \
| sed 's/[^a-zA-Z0-9=+ -@]//g'
)

if [ -z "$keys" ]; then
 log info "Loaded 0 SSH public key(s) from LDAP for user: $uid"
else
 keys_count=$(echo "$keys" |  wc -l)
 log info "Loaded $keys_count SSH public key(s) from LDAP for user: $uid"
 echo "$keys"
fi