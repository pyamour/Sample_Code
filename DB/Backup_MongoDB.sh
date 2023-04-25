# Backup MongoDB  ## for demo usage

# Login to VPS 1

# Full backup

timestamp=$(date "+%Y%m%d-%H")
mkdir /workspace/backup/mongo/$timestamp
mongodump --host "replicaset/<your vps 1 IP>:27017,<your vps 2 IP>:27017" --username root --password <your password> --out /workspace/backup/mongo/$timestamp --authenticationDatabase admin -vvvvv --oplog

# Incremental backup

# Run following codes every two hours

timestamp=$(date "+%Y%m%d-%H")
mkdir /workspace/backup/mongo/$timestamp

timestart=`date -d "140 minute ago" +"%Y-%m-%d %H:%M:%S"`
last_backup_timestamp=`date -d "$timestart" +%s`

mongodump --host "replicaset/<your vps 1 IP>:27017,<your vps 2 IP>:27017" --username root --password <your password> --out /workspace/backup/mongo/$timestamp --authenticationDatabase admin -vvvvv -d local -c oplog.rs --query '{"ts":{"$gte":{"$timestamp":{"t":'$last_backup_timestamp',"i":1}}}}'


# sync files under /workspace/backup/mongo to backup storage like S3 or Azure blob storage
