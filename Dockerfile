#name of container: docker-domoticz
#versison of container: 0.1.0
FROM debian:buster-slim
LABEL MAINTAINER zaraki673  "azazel673@gmail.com"

#add repository and update the container
#Installation of nesesary package/software for this containers...
RUN apt-get update 
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -q build-essential\
                    netcat \
                    cmake  \
                    libsqlite3-dev curl libusb-dev \
                    zlib1g-dev libssl-dev git\
                    libudev-dev \
                    python3 \
                    python3-dev \
                    python \
                    python-dev \
                    python-libxml2 \
                    libxml2-dev \
                    python-pip \
                    python3-pip \
                    libxslt-dev \
                    lib32z1-dev \
                    liblua5.3 \
                    liblua5.3-dev \
                    libcereal-dev \
                    wget libssl-dev git libcurl4-gnutls-dev libcereal-dev uthash-dev rustc\
                    && apt-get clean \
                    && rm -rf /tmp/* /var/tmp/*  \
                    && rm -rf /var/lib/apt/lists/*
                    
RUN mkdir /src && cd /src

# Rebuild cmake because stable version (3.0.2) incompatible with openssl
RUN wget -O- https://github.com/Kitware/CMake/releases/download/v3.17.0/cmake-3.17.0.tar.gz | tar xzv \
            && cd cmake-3.17.0 \
            && ./configure --prefix=/opt/cmake \
            && make \
            && make install \
            && cd ../
            
RUN wget -O- https://boostorg.jfrog.io/artifactory/main/release/1.76.0/source/boost_1_76_0.tar.gz | tar zxv \
            && cd boost_1_76_0 \
            && ./bootstrap.sh \
            && ./b2 install
#RUN export $PATH=$PATH;\boost_1_70_0\bin

RUN pip3 install caldav
RUN pip3 install broadlink
RUN pip3 install pycrypto 
RUN pip3 install pyaes

#Compile Domoticz
RUN cd /opt && git clone -b development https://github.com/domoticz/domoticz.git domoticz && cd domoticz;git checkout external-libs;/opt/cmake/bin/cmake -J4 -DCMAKE_BUILD_TYPE=Release -DUSE_PYTHON=YES -DPython_ADDITIONAL_VERSIONS=3.5 . ;\
    make CMAKE_COMMAND=/opt/cmake/bin/cmake #&& make CMAKE_COMMAND=/opt/cmake/bin/cmake install 

#RUN cd /opt/domoticz/www/styles && git clone https://github.com/flatsiedatsie/domoticz-aurora-theme.git aurora && git clone https://github.com/EdddieN/machinon-domoticz_theme.git machinon

RUN mkdir -p /opt/domoticz/backup  /opt/scripts /opt/domoticz/db

VOLUME ["/opt/domoticz/scripts", "/opt/domoticz/backups",  "/opt/domoticz/db", "/opt/domoticz/plugins", " /opt/domoticz/www/images/floorplans", " /opt/domoticz/www/templates"]

# to allow access from outside of the container  to the container service
# at that ports need to allow access from firewall if need to access it outside of the server.
EXPOSE 8080 9440

# Use baseimage-docker's init system.
CMD ["/opt/domoticz/domoticz"]
