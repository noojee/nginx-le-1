#!/bin/sh

#setup ssl keys, export to pass them to le.sh
echo "ssl_key=${SSL_KEY:=le-key.pem}, ssl_cert=${SSL_CERT:=le-crt.pem}, ssl_chain_cert=${SSL_CHAIN_CERT:=le-chain-crt.pem}"
export LE_SSL_KEY=/etc/nginx/ssl/${SSL_KEY}
export LE_SSL_CERT=/etc/nginx/ssl/${SSL_CERT}
export LE_SSL_CHAIN_CERT=/etc/nginx/ssl/${SSL_CHAIN_CERT}

#read existing LE_FQDN
. /tmp/LE_FQDN.sh

echo "existing LE_FQDN is ${LE_FQDN}"

#replace LE_FQDN
sed -i "s|${LE_FQDN}|$1|g" /etc/nginx/conf.d/*.conf 2>/dev/null
sed -i "s|${LE_FQDN}|$1|g" /etc/nginx/stream.d/*.conf 2>/dev/null

# update the FQDN list on file system
echo "export LE_FQDN=$1" > /tmp/LE_FQDN.sh
chmod 755 /tmp/LE_FQDN.sh

echo "trying to update letsencrypt ..."

# read the possibly updated FQDN list from the file system
. /tmp/LE_FQDN.sh

echo "Aquiring cert for ${LE_FQDN}"
/le.sh
#on the first run remove default config, conflicting on 80
rm -f /etc/nginx/conf.d/default.conf 2>/dev/null
#on the first run enable config back
mv -v /etc/nginx/conf.d.disabled /etc/nginx/conf.d 2>/dev/null
mv -v /etc/nginx/stream.d.disabled /etc/nginx/stream.d 2>/dev/null
echo "reload nginx with ssl"
nginx -s reload
