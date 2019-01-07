FROM node:alpine

RUN apk add --no-cache git wget python2 py-requests build-base openjdk8-jre go \
    && npm install -g npm \
    && npm install -g grunt-cli

COPY google-cloud-sdk /usr/src/app/google-cloud-sdk
ENV PATH $PATH:/usr/src/app/google-cloud-sdk/bin
ENV GOPATH /usr/src/app/go
WORKDIR /usr/src/app

RUN echo 'y' | gcloud components install app-engine-python \
    && echo 'y' | gcloud components install app-engine-python-extras \
    && git clone https://github.com/webrtc/apprtc \
    && cd apprtc \
    && npm install iltorb --save-dev \
    && npm install \
    && grunt build \
    && sed -ri -e "s/(if occupancy >=) 2:/\1 99:/" out/app_engine/apprtc.py \
    && sed -ri -e "s/(if room.get_occupancy\(\) ==) 2:/\1 99:/" out/app_engine/apprtc.py \
    && sed -ri -e "s/(if room.get_occupancy\(\) >=) 2:/\1 99:/" out/app_engine/apprtc.py \
    && sed -ri -e "s/appr.tc/${HOSTNAME}/" /usr/src/app/apprtc/src/collider/collidermain/main.go
    && mkdir -p /usr/src/app/go/src \
    && ln -s /usr/src/app/apprtc/src/collider/collider /usr/src/app/go/src/collider \
    && ln -s /usr/src/app/apprtc/src/collider/collidermain /usr/src/app/go/src/collidermain \
    && ln -s /usr/src/app/apprtc/src/collider/collidertest /usr/src/app/go/src/collidertest \
    && mkdir -p /usr/src/app/go/src/golang.org/x \
    && git clone https://github.com/golang/net.git /usr/src/app/go/src/golang.org/x/net \
    && go get collidermain && go install collidermain \

EXPOSE 443
CMD dev_appserver.py --port=443 ./out/app_engine
