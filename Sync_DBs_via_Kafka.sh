# Sync databases simoutaniously via kafka  ## for demo usage


# Install kafka

docker run -itd --name kafka --network host ubuntu:18.04 

docker exec -it kafka bash 

yes | unminimize
sudo apt update
sudo apt upgrade

apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
  && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
LANG=en_US.UTF-8
export LANG
echo $LANG

sudo apt update
sudo apt install openjdk-8-jdk -y

apt install byobu
byobu

wget https://dlcdn.apache.org/kafka/3.2.1/kafka_2.13-3.2.1.tgz
tar -xzf kafka_2.13-3.2.1.tgz
cd kafka_2.13-3.2.1

bin/zookeeper-server-start.sh config/zookeeper.properties
nano config/server.properties
listeners = PLAINTEXT://0.0.0.0:9092
advertised.listeners=PLAINTEXT://<your vps ip>:9092
bin/kafka-server-start.sh config/server.properties

exit  

# Install connect

docker run -it --network host --name connect -p 8083:8083 -e GROUP_ID=1 -e CONFIG_STORAGE_TOPIC=my_connect_configs -e OFFSET_STORAGE_TOPIC=my_connect_offsets -e STATUS_STORAGE_TOPIC=my_connect_statuses -e BOOTSTRAP_SERVERS=<your vps ip>:9092 quay.io/debezium/connect:1.9
curl -H "Accept:application/json" localhost:8083/
curl -H "Accept:application/json" localhost:8083/connectors/

# Sync dbs 

# Add sync source

nano sync-src.json
{
    "name": "sync-src",
    "config": {
        "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
        "plugin.name": "pgoutput",
        "tasks.max": "1",
        "heartbeat.interval.ms": "5000",
        "database.hostname": "<your source db server ip>",
        "database.port": "5432",
        "database.user": "postgres",
        "database.password": "<your source db password>",
        "database.dbname" : "<your source db name>",
        "database.server.id": "184055",
        "database.server.name": "syncdb",
        "table.include.list": "public.(.*)",
        "heartbeat.interval.ms": "5000",
        "slot.name": "debezium_src_sync",
        "publication.name": "publication_src_sync",
        "transforms": "route",
        "transforms.route.type": "org.apache.kafka.connect.transforms.RegexRouter",
        "transforms.route.regex": "([^.]+)\\.([^.]+)\\.([^.]+)",
        "transforms.route.replacement": "db_sync.$3"
    }
}

curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d @sync-src.json
curl -i -X GET -H "Accept:application/json" localhost:8083/connectors/sync-src/status

# Add destination

nano sync-sink.json

{
    "name": "sync-sink",
    "config": {
        "connector.class": "io.confluent.connect.jdbc.JdbcSinkConnector",
        "tasks.max": "1",
        "topics.regex": "db_sync.(.*)",
        "connection.url": "jdbc:postgresql://<your destination db server ip>:5432/monitor?user=postgres&password=<your destination db password>",
        "transforms": "dropPrefix,unwrap",
        "transforms.dropPrefix.type": "org.apache.kafka.connect.transforms.RegexRouter",
        "transforms.dropPrefix.regex": "db_sync.(.*)",
        "transforms.dropPrefix.replacement": "$1",
        "table.name.format": "${topic}",
        "transforms.unwrap.type": "io.debezium.transforms.ExtractNewRecordState",
        "auto.create": "true",
        "auto.evolve": "true",
        "insert.mode": "upsert",
        "pk.fields": "id",
        "pk.mode": "record_value"
    }
}

download postgresql-42.5.0.jar confluentinc-kafka-connect-jdbc-10.6.0 from internet
docker cp postgresql-42.5.0.jar connect:/kafka/libs 
docker cp confluentinc-kafka-connect-jdbc-10.6.0 connect:/kafka/connect/
docker exec -it connect mv /kafaka/connect/confluentinc-kafka-connect-jdbc-10.6.0 /kafaka/connect/kafka-connect-jdbc
docker restart connect

curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d @sync-sink.json
curl -i -X GET -H "Accept:application/json" localhost:8083/connectors/sync-sink/status


# Monitor kafaka and sync process

docker run -p 8080:8080 \
  --name kafka-ui \
  -e KAFKA_CLUSTERS_0_NAME=sync \
  -e KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS=<your vps ip>:9092 \
  -d provectuslabs/kafka-ui:master

http://<your vps ip>:8080
