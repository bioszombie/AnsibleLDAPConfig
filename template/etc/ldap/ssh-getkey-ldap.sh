#!/bin/sh

# This script retrieves authorized SSH public keys from LDAP for a specified username.

set -eu

# Set LDAP configuration file path
LDAPCONF='/etc/ldap/ldap.conf'

# Define logging function
log() {
    local level="$1"
    local message="$2"
    logger -s -t sshd -p "auth.$level" "$message"
}

# Check if LDAP configuration file exists and is readable
if [ ! -r "$LDAPCONF" ]; then
    log err "LDAP configuration file $LDAPCONF does not exist or is not readable"
    exit 1
fi

# Validate username for permitted characters
if ! echo "$1" | grep -qE '^[a-zA-Z0-9._-]+$'; then
    log err "Invalid characters in username: $1"
    exit 2
fi

# Retrieve SSH public keys from LDAP using environment variable for password
keys=$(ldapsearch \
    -D bind_user_name \
    -w bind_user_name_password \
    -x -LLL \
    -o ldif-wrap=no \
    "(&(sAMAccountName=$1)(sshPublicKey=*)(objectClass=user)(memberOf=cn=bind_group_name,ou=groups,dc=ldap,dc=lukeseppe,dc=com))" 'sshPublicKey' \
    | awk '/^sshPublicKey:/ { gsub(/^sshPublicKey:\s*/, ""); print }' \
    | sed -e 's/^ *map\[//' -e 's/:<nil>]$//'
)

# Log and display the result
if [ -z "$keys" ]; then
    log info "No SSH public keys found in LDAP for user: $1"
else
    keys_count=$(echo "$keys" | wc -l)
    log info "Loaded $keys_count SSH public key(s) from LDAP for user: $1"
    echo "$keys"
fi