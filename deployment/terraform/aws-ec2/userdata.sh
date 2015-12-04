#!/bin/bash -v
setenforce 0
cat <<EOF > /etc/selinux/config
SELINUX=permissive
SELINUXTYPE=targeted
EOF
