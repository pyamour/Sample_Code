# Restore MongoDB  ## for demo usage

# Login to VPS 1

################################################################################################
# setup new mongo instance

mkdir /workspace/mongodb
mkdir /workspace/mongodb/db
chmod 777 /workspace/mongodb

docker run --name mongodb-primary \
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

mongo --username root --password <your password> --authenticationDatabase admin --host <your vps 1 IP>
db.isMaster().ismaster
rs.status()
exit

################################################################################################
# get full and incremental backup files to restore

rm -r /workspace/backup
mkdir /workspace/backup
mkdir /workspace/backup/mongo
mkdir /workspace/backup/mongo/full 
mkdir /workspace/backup/mongo/incremental 

# retrieve full and incremental backup files to /workspace/backup/mongo/full and /workspace/backup/mongo/incremental 

################################################################################################
# full restore

cd /workspace/backup/mongo/full 
mkdir /workspace/backup/mongo/full/full
tar -zxvf mongo_full.tar.gx -C /workspace/backup/mongo/full/full --strip-components 4
cd /workspace/backup/mongo/full/full
mongorestore --host localhost --port 27017 --username root --password <your password> ./ --authenticationDatabase admin --oplogReplay --noIndexRestore 
cd /workspace/backup/mongo
rm -r /workspace/backup/mongo/full 

################################################################################################
# incremental restore

mongo --username root --password <your password> --authenticationDatabase admin --host <your vps 1 IP>
use admin 
show users
db.createRole(
   {
     role: "interalUseOnlyOplogRestore",
     privileges: [
       { resource: { anyResource: true }, actions: [ "anyAction" ] }
     ],
     roles: []
   }
)
db.grantRolesToUser(
   "root",
   [ "interalUseOnlyOplogRestore" ]
)

cd /workspace/backup/mongo/incremental
mkdir /workspace/backup/mongo/incremental/incremental

for i in *.tar.gz
do
    echo $i
    rm -r /workspace/backup/mongo/incremental/incremental
    mkdir /workspace/backup/mongo/incremental/incremental
    tar -zxvf $i -C /workspace/backup/mongo/incremental/incremental --strip-components 4
    mongorestore --host localhost --port 27017 --username root --password <your password> ./incremental/ --authenticationDatabase admin -vvvvv --oplogReplay 
done

cd /workspace/backup
rm -r /workspace/backup/mongo/incremental
