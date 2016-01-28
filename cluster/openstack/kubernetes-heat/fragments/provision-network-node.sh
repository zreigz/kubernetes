#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

. /etc/sysconfig/heat-params

FLANNEL_ETCD_URL="http://${MASTER_IP}:4379"

# Install flannel for overlay
if ! which flanneld >/dev/null 2>&1; then
  yum install -y flannel
fi

cat <<EOF >/etc/sysconfig/flanneld
FLANNEL_ETCD="${FLANNEL_ETCD_URL}"
FLANNEL_ETCD_KEY="/coreos.com/network"
FLANNEL_OPTIONS="-iface=eth0 --ip-masq"
EOF

systemctl enable flanneld
systemctl restart flanneld
