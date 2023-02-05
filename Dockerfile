# based on debian
FROM debian:bookworm-slim

# source code url
ENV SOURCE="https://www.ispyconnect.com/api/Agent/DownloadLocation4?platform=Linux64&fromVersion=0"
# default binary locations
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# https://github.com/doitandbedone/ispyagentdvr-docker/commit/66e568863f4b238f089e2d760360ee27869f3315
ENV MALLOC_TRIM_THRESHOLD_=100000

ARG DEBIAN_FRONTEND=noninteractive
ARG DEBCONF_NOWARNINGS=yes
ARG TZ=Europe/Berlin
ARG name
    

# prepare debian
RUN apt-get update \
    && apt-get install -y wget curl unzip software-properties-common alsa-utils tzdata init
    
# install iSpy Agent DVR
RUN wget -c $(wget -qO- ${SOURCE} | tr -d '"') -O agent.zip; \
    unzip agent.zip -d /agent && \
    rm agent.zip
    
# libgdiplus used for smart detection
RUN apt-get install -y libgdiplus

# install ffmpeg
RUN apt-get install -y ffmpeg

# clean up
RUN apt-get -y --purge remove unzip wget \ 
    && apt autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# set permission
RUN echo "Adding executable permissions" && \
    chmod +x /agent/Agent && \
    chmod +x /agent/agent-register.sh && \
    chmod +x /agent/agent-reset.sh && \
    chmod +x /agent/agent-reset-local-login.sh

# webui port
EXPOSE 8090

# webRTC - STUN server port
EXPOSE 3478/udp

# webRTC - TURN server UDP port range
EXPOSE 50000-50010/udp

# data volumes
VOLUME ["/agent/Media/XML", "/agent/Media/WebServerRoot/Media", "/agent/Commands"]

# service entrypoint
CMD ["/agent/Agent"] 
