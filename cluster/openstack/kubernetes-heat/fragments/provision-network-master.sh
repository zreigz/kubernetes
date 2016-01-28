#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

. /etc/sysconfig/heat-params

FLANNEL_ETCD_URL="http://${MASTER_IP}:4379"

# Install etcd for flannel data
if ! which etcd > /dev/null 2>&1; then
  curl -L  https://github.com/coreos/etcd/releases/download/v2.2.5/etcd-v2.2.5-linux-amd64.tar.gz -o etcd-v2.2.5-linux-amd64.tar.gz
  tar -C /usr/local -xzf etcd-v2.2.5-linux-amd64.tar.gz
  export PATH=$PATH:/usr/local/etcd-v2.2.5-linux-amd64
  mkdir /usr/lib/etcd
  cat <<EOF > /etc/systemd/system/etcd.service
[Unit]
Description=ETCD service
Requires=network.target
After=network.target

[Service]
Environment=ETCD_DATA_DIR=/usr/lib/etcd
Environment=ETCD_NAME=flannel
Environment=ETCD_LISTEN_PEER_URLS=http://${MASTER_IP}:4380
Environment=ETCD_LISTEN_CLIENT_URLS=http://${MASTER_IP}:4379
Environment=ETCD_INITIAL_ADVERTISE_PEER_URLS=http://${MASTER_IP}:4380
Environment=ETCD_ADVERTISE_CLIENT_URLS=http://${MASTER_IP}:4379
Environment=ETCD_INITIAL_CLUSTER=flannel=http://${MASTER_IP}:4380

Type=notify
User=root
Group=root
Restart=on-failure
ExecStart=/usr/local/etcd-v2.2.5-linux-amd64/etcd

[Install]
WantedBy=multi-user.target
EOF

fi
systemctl enable etcd
systemctl start etcd

# Install flannel for overlay
if ! which flanneld > /dev/null 2>&1; then
  apt-get install -y linux-libc-dev gcc git
  curl -L https://storage.googleapis.com/golang/go1.5.3.linux-amd64.tar.gz -o go.tar.gz
  tar -C /usr/local -xzf go.tar.gz
  mkdir /usr/lib/go
  export PATH=$PATH:/usr/local/go/bin
  export GOPATH=/usr/lib/go
  export GOBIN=$GOPATH/bin
  export PATH=$GOPATH:$GOBIN:$PATH
  git clone https://github.com/coreos/flannel.git
  cd flannel; ./build
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

  cat <<EOF > /etc/systemd/system/flanneld.service
[Unit]
Description=Flannel
Requires=network.target
After=network.target

[Service]
Type=simple
User=root
Group=root
Restart=on-failure
ExecStart=/flannel/bin/flanneld --etcd-endpoints ${FLANNEL_ETCD_URL} --etcd-prefix=/coreos.com/network --iface=eth0 --ip-masq=true

[Install]
WantedBy=multi-user.target
EOF

systemctl enable flanneld
systemctl start flanneld
