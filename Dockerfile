#name of container: docker-domoticz
#versison of container: 0.1.0
FROM debian
MAINTAINER Cyrille Nofficial  "cynoffic@cyrilix.fr"

ENV VERSION=2.3530

#add repository and update the container
#Installation of nesesary package/software for this containers...
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y -q build-essential\
                    cmake libboost-dev libboost-thread-dev libboost-system-dev \
                    libsqlite3-dev curl libcurl4-openssl-dev libusb-dev \
                    zlib1g-dev libssl-dev git\
                    libudev-dev \
                    mplayer2 \
                    python3 \
                    && apt-get clean \
                    && rm -rf /tmp/* /var/tmp/*  \
                    && rm -rf /var/lib/apt/lists/*
#Compile OpenZWave
RUN git clone https://github.com/OpenZWave/open-zwave.git ;\
    ln -s open-zwave open-zwave-read-only ; \
    cd open-zwave; \
    make; cd ..

#Compile Domoticz
RUN git clone https://github.com/domoticz/domoticz.git domoticz ;\
    cd domoticz; git checkout ${VERSION} ;cmake -J4 -DCMAKE_BUILD_TYPE=Release . ;\
    make && make install &&\
    cd ../ && rm -r domoticz

RUN mkdir -p /opt/domoticz/db/ /opt/domoticz/backup  /scripts
VOLUME ["/opt/domoticz/scripts"]

# to allow access from outside of the container  to the container service
# at that ports need to allow access from firewall if need to access it outside of the server.
EXPOSE 8080

# Use baseimage-docker's init system.
CMD ["/opt/domoticz/domoticz"]
