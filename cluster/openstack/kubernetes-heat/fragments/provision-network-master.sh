#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

. /etc/sysconfig/heat-params

FLANNEL_ETCD_URL="http://${MASTER_IP}:4379"

# Install etcd for flannel data
if ! which etcd > /dev/null 2>&1; then
  yum install -y etcd
fi

cat <<EOF > /etc/etcd/etcd.conf
ETCD_NAME=flannel
ETCD_DATA_DIR="/var/lib/etcd/flannel.etcd"
ETCD_LISTEN_PEER_URLS="http://${MASTER_IP}:4380"
ETCD_LISTEN_CLIENT_URLS="http://${MASTER_IP}:4379"
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://${MASTER_IP}:4380"
ETCD_INITIAL_CLUSTER="flannel=http://${MASTER_IP}:4380"
ETCD_ADVERTISE_CLIENT_URLS="${FLANNEL_ETCD_URL}"
EOF
systemctl enable etcd
systemctl restart etcd

# Install flannel for overlay
if ! which flanneld > /dev/null 2>&1; then
  yum install -y flannel
fi

cat <<EOF > /etc/flannel-config.json
{
  "Network": "${CONTAINER_SUBNET}",
  "SubnetLen": 24,
  "Backend": {
    "Type": "udp",
    "Port": 8285
  }
}
EOF

etcdctl -C ${FLANNEL_ETCD_URL} set /coreos.com/network/config < /etc/flannel-config.json

cat <<EOF > /etc/sysconfig/flanneld
FLANNEL_ETCD="${FLANNEL_ETCD_URL}"
FLANNEL_ETCD_KEY="/coreos.com/network"
FLANNEL_OPTIONS="-iface=eth0 --ip-masq"
EOF

systemctl enable flanneld
systemctl restart flanneld
