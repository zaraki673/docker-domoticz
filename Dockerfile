#name of container: docker-domoticz
#versison of container: 0.1.0
FROM debian
LABEL MAINTAINER zaraki673  "azazel673@gmail.com"

#add repository and update the container
#Installation of nesesary package/software for this containers...
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y -q build-essential\
                    netcat \
                    cmake  \
                    libsqlite3-dev curl libcurl4-openssl-dev libusb-dev \
                    zlib1g-dev libssl-dev git\
                    libudev-dev \
                    mplayer2 \
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
                    wget \
                    && apt-get clean \
                    && rm -rf /tmp/* /var/tmp/*  \
                    && rm -rf /var/lib/apt/lists/*
         
# Rebuild cmake because stable version (3.0.2) incompatible with openssl
RUN wget -O- https://github.com/Kitware/CMake/releases/download/v3.14.5/cmake-3.14.5.tar.gz | tar xzv \
            && cd cmake-3.14.5 \
            && ./configure --prefix=/opt/cmake \
            && make \
            && make install \
            && cd ../
            
RUN wget -O- https://dl.bintray.com/boostorg/release/1.70.0/source/boost_1_70_0.tar.gz | tar zxv \
            && cd boost_1_70_0 \
            && ./bootstrap.sh \
            && ./b2 install
#RUN export $PATH=$PATH;\boost_1_70_0\bin

RUN pip3 install caldav
RUN pip3 install broadlink
RUN pip3 install pycrypto 
RUN pip3 install pyaes

#Compile Domoticz
RUN git clone -b development https://github.com/domoticz/domoticz.git domoticz ;\
    cd domoticz;/opt/cmake/bin/cmake -J4 -DCMAKE_BUILD_TYPE=Release -DUSE_PYTHON=YES -DPython_ADDITIONAL_VERSIONS=3.5 . ;\
    make CMAKE_COMMAND=/opt/cmake/bin/cmake && make CMAKE_COMMAND=/opt/cmake/bin/cmake install &&\
    cd ../ && rm -r domoticz && rm -r /opt/cmake

RUN cd /opt/domoticz/www/styles && git clone https://github.com/flatsiedatsie/domoticz-aurora-theme.git aurora && git clone https://github.com/EdddieN/machinon-domoticz_theme.git machinon

RUN mkdir -p /opt/domoticz/db/ /opt/domoticz/backup  /scripts /opt/domoticz/db



RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install openssh-server sudo
ADD set_root_pw.sh /set_root_pw.sh
ADD run.sh /run.sh
RUN chmod +x /*.sh
RUN mkdir -p /var/run/sshd && sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config \
  && sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
  && touch /root/.Xauthority \
  && true

## Set a default user. Available via runtime flag `--user docker`
## Add user to 'staff' group, granting them write privileges to /usr/local/lib/R/site.library
## User should also have & own a home directory, but also be able to sudo
RUN useradd docker \
        && passwd -d docker \
        && mkdir /home/docker \
        && chown docker:docker /home/docker \
        && addgroup docker staff \
        && addgroup docker sudo \
        && true




VOLUME ["/opt/domoticz/scripts", "/opt/domoticz/backups",  "/opt/domoticz/db", "/opt/domoticz/plugins", " /opt/domoticz/www/images/floorplans", " /opt/domoticz/www/templates"]

# to allow access from outside of the container  to the container service
# at that ports need to allow access from firewall if need to access it outside of the server.
EXPOSE 8080, 22, 9440

# Use baseimage-docker's init system.
CMD ["/opt/domoticz/domoticz"]
