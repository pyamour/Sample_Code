# Restore PostgreSQL  ## for demo usage

# Login to VPS 1

###############################################################################################
# Create new Postgresql instance

sudo rm -r /workspace/postgresql
mkdir /workspace/postgresql

sudo nano /etc/hosts
<your vps 1 IP>     pg-0
<your vps 2 IP>     pg-1

sudo docker run   --name pg-0 \
  --network host \
  --env REPMGR_PARTNER_NODES=pg-0,pg-1 \
  --env REPMGR_PRIMARY_HOST=pg-0 \
  --env REPMGR_NODE_NAME=pg-0 \
  --env REPMGR_NODE_NETWORK_NAME=pg-0 \
  --env REPMGR_PASSWORD=<your replication password> \
  --env POSTGRESQL_PASSWORD=<your db password> \
  -v /workspace/postgresql:/bitnami/postgresql \
  -p 5432:5432 \
  bitnami/postgresql-repmgr:13.5.0

###############################################################################################
# Change PG config file to restore

docker exec -it  --user root pg-0 bash

mkdir /bitnami/postgresql/backup
mkdir /bitnami/postgresql/backup/pg_dumpall
mkdir /bitnami/postgresql/backup/pg_dumpswp
mkdir /bitnami/postgresql/backup/pg_basebackup
mkdir /bitnami/postgresql/backup/wal_archive
chmod 777 /bitnami/postgresql/backup /bitnami/postgresql/backup/pg_dumpall /bitnami/postgresql/backup/pg_basebackup /bitnami/postgresql/backup/wal_archive

sed -i "s/postgresql_configure_connections/postgresql_set_property \"restore_command\" \'cp \/bitnami\/postgresql\/backup\/wal_archive\/\%f \"\%p\"\'\r\n    postgresql_configure_connections/g" /opt/bitnami/scripts/librepmgr.sh

sed -i "s/\"\$POSTGRESQL_DATA_DIR\"\/recovery.signal//g" /opt/bitnami/scripts/libpostgresql.sh

exit

sudo touch /workspace/postgresql/data/recovery.signal

###############################################################################################
# Prepare PG data and backup folder to restore

sudo docker stop pg-0

sudo chmod 777 /workspace/postgresql -R 

# remove initialized data brought by new instance
sudo mv /workspace/postgresql/data /workspace/postgresql/data_initial
mkdir /workspace/postgresql/data 

# get PG basebackup files and incremental backup files from blob to /workspace/postgresql/backup/pg_basebackup and /workspace/postgresql/backup/wal_archive

# recover pg basebackup
cd /workspace/postgresql/backup/pg_basebackup
tar -zxvf pg_basebackup.tar.gz -C /workspace/postgresql/data --strip-components 4
sudo chmod 777  /workspace/postgresql/data -R

# remove pg wal with recovered base backup
sudo rm -r /workspace/postgresql/data/pg_wal/

# get pg wal
sudo mkdir /workspace/postgresql/data/pg_wal/
sudo chmod 777 /workspace/postgresql/data/pg_wal/
# Copy unarchived PG incremental backup files pg_wal from failed database server to /workspace/postgresql/data/pg_wal/
# Copy /workspace/postgresql/backup/wal_archive to /workspace/postgresql/data/pg_wal/

# clean initial pg wal 
sudo rm -r /workspace/postgresql/pg_wal

sudo chmod 777 -R /workspace/postgresql/data/pg_wal/

sudo chown 1001 /workspace/postgresql/data
sudo chgrp root /workspace/postgresql/data

sudo chmod 777  /workspace/postgresql/data -R

###############################################################################################
# Restore PG

sudo docker start pg-0
sudo docker logs pg-0

###############################################################################################
# Remove PG restore settings in config file

sudo docker exec -it --user root pg-0 bash

ls /bitnami/postgresql/data
rm /bitnami/postgresql/data/recovery.signal

sed -i "s/\"\$POSTGRESQL_DATA_DIR\"\/standby.signal/\"\$POSTGRESQL_DATA_DIR\"\/standby.signal\r\n        \"\$POSTGRESQL_DATA_DIR\"\/recovery.signal/g" /opt/bitnami/scripts/libpostgresql.sh

sed -i "s/postgresql_set_property \"restore_command\"/#postgresql_set_property \"restore_command\"/g" /opt/bitnami/scripts/librepmgr.sh

exit

sudo docker restart pg-0
