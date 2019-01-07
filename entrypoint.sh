#/bin/sh

exec dev_appserver.py --host=0.0.0.0 --port=80 ./out/app_engine

exec /usr/src/app/go/bin/collidermain -port=8089 -tls=false -room-server="http://${HOSTNAME}"

exec /usr/src/app/coturn/bin/turnserver --no-auth
