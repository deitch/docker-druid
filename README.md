# Docker Druid

Tags:

- 0.9.2, 0.9, latest ([Dockerfile](https://github.com/deitch/docker-druid/blob/master/Dockerfile))

## What is Druid?

Druid is an open-source analytics data store designed for business intelligence (OLAP) queries on event data. Druid provides low latency (real-time) data ingestion, flexible data exploration, and fast data aggregation. Existing Druid deployments have scaled to trillions of events and petabytes of data. Druid is most commonly used to power user-facing analytic applications.


## Running

Druid being a complex system, the best way to get up and running with a cluster is to use the docker-compose file provided.

Clone our public repository:

```
git clone git@github.com:deitch/docker-druid.git
```

and run :

```
docker-compose up
```

The compose file will launch :

- 1 [zookeeper](https://hub.docker.com/r/znly/zookeeper/) node
- 1 postgres database

and the following druid services :

- 1 broker
- 1 overlord
- 1 middlemanager
- 1 historical

The image contains the full druid distribution and use the default druid cli. If no command is provided the image will run as a broker.

If you plan to use this image on your local machine, be careful with the JVM heap spaces required by default (some services are launched with 15gb heap space).

## Configuration

You can override *any* setting in `common.runtime.properties` and `runtime.properties` by setting an environment variable that begins with `druid_` and matches the property name, with `.` replaced by `_`.

For example, if you want to override the setting `druid.metadata.storage.connector.user` and set it to `DBUSER`, set the environment variable `druid_metadata_storage_connector_user=DBUSER`. All case is respected.

Thus `druid_metadata_storage_connector_connectURI=jdbc:postgresql://dbSErver/db` will be converted to `druid.metadata.storage.connector.connectURI=jdbc:postgresql://dbSErver/db`

In addition, certain environment variables have special properties. If unset, they use the defaults configured in `./conf/druid/`. If set, they override the properties.

* `DRUID_XMX`: `java -Xmx${DRUID_XMX}`
* `DRUID_XMS`: `java -Xms${DRUID_XMS}`
* `DRUID_NEWSIZE`: `java -XX:NewSize=${DRUID_NEWSIZE}``
* `DRUID_MAXNEWSIZE` `java -XX:MaxNewSize=${DRUID_MAXNEWSIZE}``
* `DRUID_USE_CONTAINER_IP`: if `true`, sets `druid.host` to be the IP of `eth0` inside the container.
* `DRUID_HOSTNAME`: Convenience, equivalent to `druid_host=somename`
* `DRUID_LOGLEVEL`: Convenience, equivalent to `java -Ddruid.emitter.logging.logLevel=${DRUID_LOGLEVEL}`.

Priority overrides: lowercase settings, e.g. `druid_host`, **always** override special variables, e.g. `DRUID_HOSTNAME`.

Within the special variables, `DRUID_HOSTNAME` overrides `DRUID_USE_CONTAINER_IP`.

## Authors

- Jean-Baptiste DALIDO <jb@zen.ly>
- Clément REY <clement@zen.ly>
- Avi Deitcher <https://github.com/deitch>
