#!/bin/bash

set -e

if [[ ! -f /opt/mongodb_password ]]; then
    echo "No mongodb password defined"
    exit 1
fi
if [[ ! -f /opt/mongodb/initialized ]]; then
    mkdir -p /opt/mongodb
    /usr/bin/mongod --bind_ip=127.0.0.1 --dbpath=/opt/mongodb --noauth --fork --syslog
    DB_PASSWORD="$(cat "/opt/mongodb_password")"
    sleep 2s
    echo "Creating admin user..."
    mongo <<EOF
use admin
db.addUser({user: "admin", pwd:"${DB_PASSWORD}", roles:["clusterAdmin", "userAdminAnyDatabase"]})
EOF
    kill $(pidof mongod)
    sleep 8s
    chown -R mongodb:mongodb /opt/mongodb
    chmod -R 755 /opt/mongodb
    touch /opt/mongodb/initialized
fi

exec /usr/bin/mongod --dbpath=/opt/mongodb --auth
