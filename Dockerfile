FROM node:alpine

RUN apk add --no-cache git wget python2 py-requests build-base openjdk8-jre \
    && mkdir -p /usr/src/app \
    && cd /usr/src/app \
    && npm install -g npm \
    && npm install -g grunt-cli

ADD google-cloud-sdk /usr/src/app

RUN  echo 'y' | ./google-cloud-sdk/bin/gcloud components install app-engine-python \
    && echo 'y' | ./google-cloud-sdk/bin/gcloud components install app-engine-python-extras \
    && git clone https://github.com/webrtc/apprtc \
    && cd apprtc \
    && npm install iltorb --save-dev \
    && npm install \
    && grunt build \
    && sed -ri -e "s/(if occupancy >=) 2:/\1 99:/" out/app_engine/apprtc.py \
    && sed -ri -e "s/(if room.get_occupancy\(\) ==) 2:/\1 99:/" out/app_engine/apprtc.py \
    && sed -ri -e "s/(if room.get_occupancy\(\) >=) 2:/\1 99:/" out/app_engine/apprtc.py

WORKDIR /usr/src/app/scratch-gui
EXPOSE 80
CMD ./google-cloud-sdk/bin/dev_appserver.py --port=80 ./out/app_engine
