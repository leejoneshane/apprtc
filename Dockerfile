FROM node:alpine

RUN apk add --no-cache git wget python2 py-requests build-base openjdk8-jre go libevent-dev openssl-dev sqlite-dev linux-headers \
    && npm install -g npm \
    && npm install -g grunt-cli
COPY entrypoint.sh /entrypoint.sh
COPY google-cloud-sdk /usr/src/app/google-cloud-sdk
COPY index.js /usr/src/app/rest/index.js
ENV PATH $PATH:/usr/src/app/google-cloud-sdk/bin
ENV GOPATH /usr/src/app/go
WORKDIR /usr/src/app

RUN chmod +x /entrypoint.sh \
    && echo 'y' | gcloud components install app-engine-python \
    && echo 'y' | gcloud components install app-engine-python-extras \
    && git clone https://github.com/webrtc/apprtc \
    && cd /usr/src/app/apprtc \
    && npm install iltorb --save-dev \
    && npm install \
    && grunt build \
    && sed -ri -e "s/(if occupancy >=) 2:/\1 99:/" out/app_engine/apprtc.py \
    && sed -ri -e "s/(if room.get_occupancy\(\) ==) 2:/\1 99:/" out/app_engine/apprtc.py \
    && sed -ri -e "s/(if room.get_occupancy\(\) >=) 2:/\1 99:/" out/app_engine/apprtc.py \
    && cd /usr/src/app \
    && mkdir -p /usr/src/app/go/src \
    && cp -Rp /usr/src/app/apprtc/src/collider/collider /usr/src/app/go/src \
    && cp -Rp /usr/src/app/apprtc/src/collider/collidermain /usr/src/app/go/src \
    && cp -Rp /usr/src/app/apprtc/src/collider/collidertest /usr/src/app/go/src \
    && mkdir -p /usr/src/app/go/src/golang.org/x \
    && git clone https://github.com/golang/net.git /usr/src/app/go/src/golang.org/x/net \
    && go get collidermain && go install collidermain \
    && git clone https://github.com/coturn/coturn \
    && cd /usr/src/app/coturn \
    && ./configure \
    && make \
    && cd /usr/src/app/rest \
    && npm install express --save

EXPOSE 80 3033 8089 3478 3478/udp 5349 5349/udp 5766 49152-65535/udp
CMD /entrypoint.sh
