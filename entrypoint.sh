#/bin/sh
sed -ri -e "s/(min-port=) .*/\1 $MIN_PORT/" /etc/turnserver.conf
sed -ri -e "s/(max-port=) .*/\1 $MAX_PORT/" /etc/turnserver.conf
if [ "${SSL}" == "no" ]; then
  sed -ri -e "s/(roomLink=roomLink\.substring\(\"http\",\")https(\"\);)/\1http\2" /usr/src/app/apprtc/out/app_engine/js/apprtc.debug.js
else
  sed -ri -e "s/(roomLink=roomLink\.substring\(\"http\",\")http(\"\);)/\1https\2" /usr/src/app/apprtc/out/app_engine/js/apprtc.debug.js
fi
exec dev_appserver.py --enable_host_checking=false --host=0.0.0.0 --port=80 /usr/src/app/apprtc/out/app_engine

exec /root/go/bin/collidermain -port=8089 -tls=false -room-server="http://${HOSTNAME}"

exec /usr/src/app/coturn/bin/turnserver --no-auth

exec node /usr/src/app/rest/index.js
