# apprtc
This is docker images for [apprtc](https://github.com/webrtc/apprtc).

To run the apprtc, you must mapping tcp 80 port when run the container first time, use command below:

docker run -p 80:80 --name meeting -d leejoneshane/apprtc:node
