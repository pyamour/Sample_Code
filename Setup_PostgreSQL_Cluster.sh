# Set up PostgreSQL Cluster  ## for demo usage

# Login to VPS 1

sudo docker pull bitnami/postgresql-repmgr:13.5.0
mkdir /workspace/postgresql

sudo nano /etc/hosts
<your vps 1 IP>    pg-0
<your vps 2 IP>    pg-1

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


# Login to VPS 2

sudo docker pull bitnami/postgresql-repmgr:13.5.0
mkdir /workspace/postgresql

sudo nano /etc/hosts
<your vps 1 IP>    pg-0
<your vps 2 IP>    pg-1

sudo docker run  --name pg-1 \
  --network host \
  --env REPMGR_PARTNER_NODES=pg-0,pg-1 \
  --env REPMGR_NODE_NAME=pg-1 \
  --env REPMGR_NODE_NETWORK_NAME=pg-1 \
  --env REPMGR_PRIMARY_HOST=pg-0 \
  --env REPMGR_PASSWORD=<your replication password> \
  --env POSTGRESQL_PASSWORD=<your db password> \
  -v /workspace/postgresql:/bitnami/postgresql \
  -p 5432:5432 \
  bitnami/postgresql-repmgr:13.5.0

