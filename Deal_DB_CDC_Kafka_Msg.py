# Deal with kafka's DB CDC message  ## for demo usage


############################################################################################################################
# Prepare CDC topic in Kafka

'''
# Log in Kafka connect vps

nano cdc.json

{
  "name": "pg-cdc",
  "config": {
    "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
    "plugin.name": "pgoutput",
    "database.hostname": "<your db server ip>",
    "database.port": "5432",
    "database.user": "postgres",
    "database.password": "<your db server password>",
    "database.dbname" : "<your db name>",
    "database.server.name": "db-cdc",
    "table.include.list": "public.(.*)",
    "heartbeat.interval.ms": "5000",
    "slot.name": "cdc_debezium",
    "publication.name": "cdc_publication",
    "transforms": "AddPrefix",
    "transforms.AddPrefix.type": "org.apache.kafka.connect.transforms.RegexRouter",
    "transforms.AddPrefix.regex": "pg-cdc.public.(.*)",
    "transforms.AddPrefix.replacement": "data.cdc"
  }
}
curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" <your vps ip>:8083/connectors/ -d @cdc.json
curl -i -X GET -H "Accept:application/json" <your vps ip>:8083/connectors/pg-cdc
'''


############################################################################################################################
# Process cdc msgs

from kafka import KafkaConsumer, TopicPartition
from kafka.errors import KafkaError

def deal_msg(msg):
    table = str(msg['payload']['source']['table'])
    if table != '<your destination table name>':
        return
    msg = msg['payload']['after']
    if not msg:
        return
    value = msg["<your destination column name>"]
    if value:
        # deal with value
        pass

def cdc_value_deserializer(x):
    if x:
        return loads(x.decode('utf-8'))
    else:
        return {}

def main():
    tp = TopicPartition('data.cdc', 0)
    consumer = KafkaConsumer(client_id='Deal_DB_CDC_Kafka_Msg.py', group_id='Deal_DB_CDC_Kafka_Msg',
                             bootstrap_servers=['<your kafka server ip>:9092'],
                             value_deserializer=lambda x: cdc_value_deserializer(x))
    consumer.assign([tp])

    lastOffset = consumer.end_offsets([tp])[tp]
    pos = consumer.position(tp)
    print("last offset:", str(lastOffset))
    print('position', str(pos))

    for msg in consumer:
        print('Offset: ' + str(msg.offset))
        msg = msg.value
        if msg:
            # print('{}'.format(msg))
            # print(msg['payload']['source']['table'])
            # print(msg['payload']['before'])
            # print(msg['payload']['after'])
            deal_msg(msg)
            try:
                consumer.commit()
            except KafkaError as exc:
                print("Exception during consumer.commit - {}".format(exc))


if __name__ == "__main__":
    main()
