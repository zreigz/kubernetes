#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

. /etc/sysconfig/heat-params

FLANNEL_ETCD_URL="http://${MASTER_IP}:4379"

# Install flannel for overlay
if ! systemctl is-active flanneld > /dev/null 2>&1; then
  apt-get install -y linux-libc-dev gcc git
  curl -L https://storage.googleapis.com/golang/go1.5.3.linux-amd64.tar.gz -o go.tar.gz
  tar -C /usr/local -xzf go.tar.gz
  mkdir -p /usr/lib/go
  export PATH=$PATH:/usr/local/go/bin
  export GOPATH=/usr/lib/go
  export GOBIN=$GOPATH/bin
  export PATH=$GOPATH:$GOBIN:$PATH
  git clone https://github.com/coreos/flannel.git
  cd flannel; ./build
fi

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