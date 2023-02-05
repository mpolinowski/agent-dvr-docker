This Dockerfile for the [iSpy Agent DVR](https://www.ispyconnect.com/features.aspx) is based on the [(un)official docker image](https://hub.docker.com/r/doitandbedone/ispyagentdvr) provided on the iSpy Download page. But it uses Debian Bookworm-Slim instead of Ubuntu Stable as a base image to reduce the container size.


You can build the image by cloning the repository and running the following command from inside the directory:


```bash
docker build -t agent-dvr .
```

To persist data generated inside the running container later we have to create 3 directories on the host system (you can choose the location at will - but you will need to adjust the RUN command below accordingly):


```bash
sudo mkdir -p /opt/dvr-agent/{config,media,commands}
sudo chown -R myuser /opt/dvr-agent/*
```

You need to expose the port `8090` for the web user interface. The ports `3478` (__STUN__) and `50000` - `50010`  (__TURN__) are needed for the webRTC video connection:


```bash
docker run -it -p 8090:8090 -p 3478:3478/udp -p 50000-50010:50000-50010/udp \
-v /opt/dvr-agent/config/:/agent/Media/XML/ \
-v /opt/dvr-agent/media/:/agent/Media/WebServerRoot/Media/ \
-v /opt/dvr-agent/commands:/agent/Commands/ \
-e TZ=Europe/Berlin \
--name agent-dvr agent-dvr:latest
```


This command runs the container process attached to your terminal and allows you to spot eventual error messages. To run the container in the background and make sure that it is restarted automatically if needed use the following command:


```bash
docker run --restart=unless-stopped -d -p 8090:8090 -p 3478:3478/udp -p 50000-50010:50000-50010/udp \
-v /opt/dvr-agent/config/:/agent/Media/XML/ \
-v /opt/dvr-agent/media/:/agent/Media/WebServerRoot/Media/ \
-v /opt/dvr-agent/commands:/agent/Commands/ \
-e TZ=Europe/Berlin \
--name agent-dvr agent-dvr:latest
```


You can kill the container with the following commang:


```bash
docker rm -f agent-dvr
```

https://www.ispyconnect.com/userguide-agent-DVR.aspx#installing