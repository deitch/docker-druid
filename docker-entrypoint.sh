#!/bin/bash
set -e

# are we running as debug?
if [[ -n "$DEBUG" ]]; then
 set -x
fi

# Run as broker if needed
if [ "${1:0:1}" = '' ]; then
    set -- broker "$@"
fi

# 
# we cannot load up an env file directly, since some properties are invalid, e.g. property_s3_http-port - bash will not accept the dash char as a var name
# instead we will read only those props that are real (do not begin with property_), and load the rest later
if [[ -e /druid.env ]]; then
  export $(grep -v '^property_' druid.env | grep -v '^\s*#')
fi

if [ "$DRUID_XMX" != "-" ]; then
    sed -ri 's/Xmx.*/Xmx'${DRUID_XMX}'/g' /opt/druid/conf/druid/$1/jvm.config
fi

if [ "$DRUID_XMS" != "-" ]; then
    sed -ri 's/Xms.*/Xms'${DRUID_XMS}'/g' /opt/druid/conf/druid/$1/jvm.config
fi

if [ "$DRUID_NEWSIZE" != "-" ]; then
    sed -ri 's/NewSize=.*/NewSize='${DRUID_NEWSIZE}'/g' /opt/druid/conf/druid/$1/jvm.config
fi

if [ "$DRUID_MAXNEWSIZE" != "-" ]; then
    sed -ri 's/MaxNewSize=.*/MaxNewSize='${DRUID_MAXNEWSIZE}'/g' /opt/druid/conf/druid/$1/jvm.config
fi

if [ "$DRUID_LOGLEVEL" != "-" ]; then
    sed -ri 's/druid.emitter.logging.logLevel=.*/druid.emitter.logging.logLevel='${DRUID_LOGLEVEL}'/g' /opt/druid/conf/druid/_common/common.runtime.properties
fi

if [ "$DRUID_USE_CONTAINER_IP" != "-" ]; then
    ipaddress=`ip a|grep "global eth0"|awk '{print $2}'|awk -F '\/' '{print $1}'`
    sed -ri 's/druid.host=.*/druid.host='${ipaddress}'/g' /opt/druid/conf/druid/$1/runtime.properties
fi
if [ "$DRUID_HOSTNAME" != "-" ]; then
    sed -ri 's/druid.host=.*/druid.host='${DRUID_HOSTNAME}'/g' /opt/druid/conf/druid/$1/runtime.properties
fi


if [[ -n "$DRUID_EXTENSIONS" ]]; then
  finalList='"'$(echo $DRUID_EXTENSIONS | sed 's/,/", "/g' | sed 's/^+//g')'"'
  confFile=/opt/druid/conf/druid/_common/common.runtime.properties
  # did it start with + ?
  if [[ $DRUID_EXTENSIONS == +* ]]; then
    sed -i "s|\(druid.extensions.loadList=.*\)]|\1, ${finalList}]|g" $confFile
  else
    sed -i "s|\(druid.extensions.loadList=\).*|\1[${finalList}]|g" $confFile
  fi
fi

# catch all environment vars that start with property_ and set them to override.
envVars=$(env | awk -F= '/^property_/ {
    gsub("^property_","",$1)
    gsub("_",".",$1)
    print "-D"$1"="$2
}')
if [[ -e /druid.env ]]; then
  propVars=$(cat /druid.env | awk -F= '/^property_/ {
      gsub("^property_","",$1)
      gsub("_",".",$1)
      print "-D"$1"="$2
  }')
fi



java `cat /opt/druid/conf/druid/$1/jvm.config | xargs` ${envVars} ${propVars} -cp /opt/druid/conf/druid/_common:/opt/druid/conf/druid/$1:/opt/druid/lib/* io.druid.cli.Main server $@
