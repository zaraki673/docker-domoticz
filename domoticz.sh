#!/bin/sh
# `/sbin/setuser memcache` runs the given command as the user `memcache`.
# If you omit that part, the command will be run as root.
#exec /sbin/setuser memcache /usr/bin/memcached >>/var/log/domoticz.log 2>&1
exec /opt/domoticz/domoticz >>/var/log/domoticz.log 2>&1
