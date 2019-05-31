#name of container: docker-domoticz
#versison of container: 0.1.0
FROM debian
LABEL MAINTAINER zaraki673  "azazel673@gmail.com"

#add repository and update the container
#Installation of nesesary package/software for this containers...
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y -q build-essential\
                    netcat \
                    cmake libboost-dev libboost-thread-dev libboost-system-dev \
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
                    wget openssh-server \
                    && apt-get clean \
                    && rm -rf /tmp/* /var/tmp/*  \
                    && rm -rf /var/lib/apt/lists/*
         
# Rebuild cmake because stable version (3.0.2) incompatible with openssl
RUN wget -O- https://github.com/Kitware/CMake/releases/download/v3.14.4/cmake-3.14.4.tar.gz | tar xzv \
            && cd cmake-3.14.4 \
            && ./configure --prefix=/opt/cmake \
            && make \
            && make install \
            && cd ../


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
VOLUME ["/opt/domoticz/scripts", "/opt/domoticz/backups",  "/opt/domoticz/db", "/opt/domoticz/plugins", " /opt/domoticz/www/images/floorplans", " /opt/domoticz/www/templates"]

RUN mkdir /var/run/sshd
RUN echo 'root:screencast' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile



CMD ["/usr/sbin/sshd", "-D"]


# to allow access from outside of the container  to the container service
# at that ports need to allow access from firewall if need to access it outside of the server.
EXPOSE 8080, 9440, 22

# Use baseimage-docker's init system.
CMD ["/opt/domoticz/domoticz"]
