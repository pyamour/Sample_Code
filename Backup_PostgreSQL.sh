# Backup PostgreSQL  ## for demo usage

# Login to VPS 1

# Incremental backup

sudo docker exec -it  --user root pg-0 bash

nano /opt/bitnami/scripts/librepmgr.sh
# postgresql_set_property "archive_command" "/bin/true"
postgresql_set_property "archive_command" "test ! -f /bitnami/postgresql/backup/wal_archive/%f \&\& cp %p /bitnami/postgresql/backup/wal_archive/%f"
postgresql_set_property "archive_timeout" "3600"

exit

sudo docker restart pg-0

sudo docker exec -it --user root pg-0  bash
PGPASSWORD=<your password> pg_basebackup -U repmgr -D /bitnami/postgresql/backup/pg_basebackup
pg_verifybackup /bitnami/postgresql/backup/pg_basebackup

exit


# Full backup

sudo docker restart pg-0

PGPASSWORD=<your password> pg_dumpall -U postgres > /bitnami/postgresql/backup/pg_dumpall

exit


# sync files under /bitnami/postgresql/backup/ to backup storage like S3 or Azure blob storage

