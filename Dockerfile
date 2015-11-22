#name of container: docker-domoticz
#versison of container: 0.1.0
FROM quantumobject/docker-baseimage:15.04
MAINTAINER Angel Rodriguez  "angelrr7702@gmail.com"

#add repository and update the container
#Installation of nesesary package/software for this containers...
RUN echo "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc)-backports main restricted " >> /etc/apt/sources.list
RUN add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) multiverse"
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y -q build-essential\
                    cmake libboost-dev libboost-thread-dev libboost-system-dev \
                    libsqlite3-dev curl libcurl4-openssl-dev libusb-dev \
                    zlib1g-dev libssl-dev git\
                    libudev-dev \
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
    cd domoticz; cmake -DCMAKE_BUILD_TYPE=Release . ;\
    make

##startup scripts  
#Pre-config scrip that maybe need to be run one time only when the container run the first time .. using a flag to don't 
#run it again ... use for conf for service ... when run the first time ...
RUN mkdir -p /etc/my_init.d
COPY startup.sh /etc/my_init.d/startup.sh
RUN chmod +x /etc/my_init.d/startup.sh

#pre-config scritp for different service that need to be run when container image is create 
#maybe include additional software that need to be installed ... with some service running ... like example mysqld
COPY pre-conf.sh /sbin/pre-conf
RUN chmod +x /sbin/pre-conf \
    && /bin/bash -c /sbin/pre-conf \
    && rm /sbin/pre-conf
    
# to allow access from outside of the container  to the container service
# at that ports need to allow access from firewall if need to access it outside of the server. 
EXPOSE 8080

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]
