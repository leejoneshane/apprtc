FROM node:alpine

WORKDIR /usr/src/app

RUN apk add --no-cache git \
    && git clone https://github.com/ISBX/apprtc-node-server.git ./apprtc \
    && cd /usr/src/app/apprtc \
    && npm install express --save \
    && npm install \
    && sed -ri -e "s/(if \(occupancy >=) 2/\1 99/" /usr/src/app/apprtc/routes/index.js \
    && sed -ri -e "s/(if \(room.getOccupancy\(\) >) 1/\1 99/" /usr/src/app/apprtc/routes/index.js \
    && sed -ri -e "s/(if \(room.getOccupancy\(\) >=) 2/\1 100/" /usr/src/app/apprtc/routes/index.js

WORKDIR /usr/src/app/apprtc
EXPOSE 80
CMD node ./bin/www
