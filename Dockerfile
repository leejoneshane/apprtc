FROM ubuntu

RUN apt-get update \
    && apt-get -y install git nodejs npm golang lsb-release curl python-pip sqlite libevent-dev \
    && apt-get clean
    
COPY entrypoint.sh /entrypoint.sh
COPY index.js /usr/src/app/rest/index.js

ENV PATH $PATH:/usr/src/app/google-cloud-sdk/bin

WORKDIR /usr/src/app

RUN chmod +x /entrypoint.sh \
    && export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" \
    && echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
    && apt-get update && apt-get install google-cloud-sdk google-cloud-sdk-app-engine-python google-cloud-sdk-app-engine-python-extras \
    && git clone https://github.com/webrtc/apprtc \
    && cd /usr/src/app/apprtc \
    && npm install \
    && npm install -g grunt-cli \
    && pip install -r requirements.txt \
    && grunt build --force \
    && sed -ri -e "s/(if occupancy >=) 2:/\1 99:/" /usr/src/app/apprtc/out/app_engine/apprtc.py \
    && sed -ri -e "s/(if room.get_occupancy\(\) ==) 2:/\1 99:/" /usr/src/app/apprtc/out/app_engine/apprtc.py \
    && sed -ri -e "s/(if room.get_occupancy\(\) >=) 2:/\1 99:/" /usr/src/app/apprtc/out/app_engine/apprtc.py \
    && cd /usr/src/app \
    && mkdir -p /root/go/src \
    && cp -Rp /usr/src/app/apprtc/src/collider/collider /root/go/src \
    && sed -ri -e "s/(const maxRoomCapacity =) 2/\1 99/" /root/go/src/collider/room.go \
    && cp -Rp /usr/src/app/apprtc/src/collider/collidermain /root/go/src \
    && cp -Rp /usr/src/app/apprtc/src/collider/collidertest /root/go/src \
    && mkdir -p /root/go/src/golang.org/x \
    && git clone https://github.com/golang/net.git /root/go/src/golang.org/x/net \
    && go get collidermain && go install collidermain \
    && git clone https://github.com/coturn/coturn \
    && cd /usr/src/app/coturn \
    && ./configure \
    && make \
    && cd /usr/src/app/rest \
    && npm install express --save

EXPOSE 80 3033 8089 3478 3478/udp 5349 5349/udp 5766 49152-65535/udp
CMD /entrypoint.sh