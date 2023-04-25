# Set up MongoDB Cluster  ## for demo usage

# Login to VPS 1

mkdir /workspace/mongodb/db
docker pull bitnami/mongodb:4.4.10

sudo docker run --name mongodb-primary \
  -p 27017:27017 \
  -v /workspace/mongodb:/bitnami/mongodb \
  -e MONGODB_REPLICA_SET_MODE=primary \
  -e MONGODB_ADVERTISED_HOSTNAME=<your vps 1 IP> \
  -e MONGODB_REPLICA_SET_NAME=<your replica set name> \
  -e MONGODB_PORT_NUMBER=27017 \
  -e MONGODB_ROOT_USER=root \
  -e MONGODB_ROOT_PASSWORD=<your password> \
  -e MONGODB_REPLICA_SET_KEY=<your replica set key> \
  bitnami/mongodb:4.4.10


# Login to VPS 2

mkdir /workspace/mongodb/db
docker pull bitnami/mongodb:4.4.10

sudo docker run --name mongodb-secondary \
  -p 27017:27017 \
  -v /workspace/mongodb:/bitnami/mongodb \
  -e MONGODB_REPLICA_SET_MODE=secondary \
  -e MONGODB_REPLICA_SET_NAME=<your replica set name> \
  -e MONGODB_ADVERTISED_HOSTNAME=<your vps 2 IP> \
  -e MONGODB_INITIAL_PRIMARY_HOST=<your vps 1 IP> \
  -e MONGODB_INITIAL_PRIMARY_PORT_NUMBER=27017 \
  -e MONGODB_INITIAL_PRIMARY_ROOT_PASSWORD=<your password> \
  -e MONGODB_PORT_NUMBER=27017 \
  -e MONGODB_REPLICA_SET_KEY=<your replica set key> \
  bitnami/mongodb:4.4.10


# Check if cluster function normally

mongo --username root --password <your password> --authenticationDatabase admin --host <your vps 1 IP>
db.isMaster().ismaster
rs.status()

