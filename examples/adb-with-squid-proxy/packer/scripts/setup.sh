#!/bin/bash

if [ $(whoami) != root ]; then
    echo "ERROR: You need to run the script as user root or add sudo before command."
    exit 1
fi

# install squid
apt-get -y update
apt-get -y upgrade

# purge squid if it was installed
apt-get -y purge squid

# install squid, this will create /etc/squid/squid.conf
apt-get -y install squid

# create squid.conf.bk backup, if not already created
FILE=/etc/squid/squid.conf.bk

if [ -f "$FILE" ]; then
    echo "squid.conf backup exists, no change applied"
else
    cp /etc/squid/squid.conf /etc/squid/squid.conf.bk
    echo "backup created: squid.conf.bk"
fi

cat >/etc/squid/proxy-allow-list.acl <<EOF
.google.com
EOF

cat >/etc/squid/proxy-block-list.acl <<EOF
.facebook.com
.instagram.com
.twitter.com
EOF

# write into a new file, of custom setup, commented out examples are for adls
cat >squid.conf <<EOF
acl localnet src 10.179.0.0/20 # databricks vnet cidr, use your dbvnet cidr from ../../main/variables.tf
acl banned_urls dstdomain "/etc/squid/proxy-block-list.acl"
acl allow_urls dstdomain "/etc/squid/proxy-allow-list.acl"

#acl adls dstdom_regex .*\.dfs.core.windows\.net
#acl adls_specific dstdom_regex specificstorage.dfs.core.windows.net
#http_access allow adls
#http_access allow adls_specific

http_access allow localhost
http_access allow allow_urls
http_access deny banned_urls
EOF

# append the original squid conf to our squid conf
cat /etc/squid/squid.conf.bk >>squid.conf
# copy and overwrite original squid conf
cp -f squid.conf /etc/squid/

chmod 644 /etc/squid/squid.conf
chmod 644 /var/log/squid/cache.log

iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to-port 3130
# start squid
systemctl enable squid
systemctl restart squid
