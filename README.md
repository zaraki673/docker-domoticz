# docker-domoticz

Docker container for [Domoticz][3]

"Domoticz is a very light weight home automation system that lets you monitor and configure various devices like: lights, switches, various sensors/meters like temperature, rainfall, wind, Ultraviolet (UV) radiation, electricity usage/production, gas consumption, water consumption and much more. Notifications/alerts can be sent to any mobile device. The best of all, is that Domoticz is open source and completely free! You only need to invest in hardware."

## Install dependencies

  - [Docker][2]

To install docker in Ubuntu 15.04 use the commands:

    $ sudo apt-get update
    $ wget -qO- https://get.docker.com/ | sh

 To install docker in other operating systems check [docker online documentation][4]

## Usage

To run container use the command below:

    $ docker run -d -p 8080 –device /dev/ttyUSB1 -v scripts:/scripts cyrilix/docker-domoticz

or

    $ docker run -d -p xxxxx:8080 –device /dev/ttyUSB1 cyrilix/docker-domoticz

Where xxxxx is the port assigned by you for the container if not docker will assigned one for it.

Special :for Wiaomi Gateway and other plugins who use multicast use --network=host instead of -p xxxxx:8080

## Accessing the Domoticz applications:

After that check with your browser at addresses plus the port assigined by docker or you:

  - **http://host_ip:port/**

To access the container from the server that the container is running :

    $ docker exec -it container_id /bin/bash
    $ export TERM=xterm       #needed to execute some command correctly (nano,top)


## More Info

About Domoticz: [www.domoticz.com][1]

To help improve this container [docker-domoticz][5]


[1]:http://www.domoticz.com/
[2]:https://www.docker.com
[3]:https://www.domoticz.com/wiki/Linux
[4]:http://docs.docker.com
