#/bin/sh

exec dev_appserver.py --port=443 ./out/app_engine

collidermain -port=8089 -tls=true -room-server="https://${HOSTNAME}"
