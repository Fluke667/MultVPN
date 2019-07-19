#!/bin/sh

mkdir -p /dev/net
mknod /dev/net/tun c 10 200

if [ ! -f "$OVPN_TLSAUTH_KEY" ]
then

  echo " ---> Generate Openvpn TLS-Auth Key"
  openvpn \
    --genkey --secret "$OVPN_TLSAUTH_KEY"
    
else
  echo "ENTRYPOINT: tlsauth.key already exists"       
fi
    
echo " ---> Generate Openvpn file ${CLIENT_NAME}-emb.ovpn"
    echo client > ${OVPN_DIR}/${CLIENT_NAME}-emb.ovpn
    echo dev tun >> ${OVPN_DIR}/${CLIENT_NAME}-emb.ovpn
    echo proto udp >> ${OVPN_DIR}/${CLIENT_NAME}-emb.ovpn
    echo remote ${IP_ADDR} 1194 >> ${OVPN_DIR}/${CLIENT_NAME}-emb.ovpn
    echo cipher AES-256-CBC >> ${OVPN_DIR}/${CLIENT_NAME}-emb.ovpn
    echo auth SHA512 >> ${OVPN_DIR}/${CLIENT_NAME}-emb.ovpn
    echo resolv-retry infinite >> ${OVPN_DIR}/${CLIENT_NAME}-emb.ovpn
    echo redirect-gateway def1 >> ${OVPN_DIR}/${CLIENT_NAME}-emb.ovpn
    echo nobind >> ${OVPN_DIR}/${CLIENT_NAME}-emb.ovpn
    echo comp-lzo yes >> ${OVPN_DIR}/${CLIENT_NAME}-emb.ovpn
    echo persist-key >> ${OVPN_DIR}/${CLIENT_NAME}-emb.ovpn
    echo persist-tun >> ${OVPN_DIR}/${CLIENT_NAME}-emb.ovpn
    echo persist-remote-ip >> ${OVPN_DIR}/${CLIENT_NAME}-emb.ovpn
    echo user openvpn >> ${OVPN_DIR}/${CLIENT_NAME}-emb.ovpn
    echo group openvpn >> ${OVPN_DIR}/${CLIENT_NAME}-emb.ovpn
    echo verb 3 >> ${OVPN_DIR}/${CLIENT_NAME}-emb.ovpn
    #echo setenv ALLOW_PASSWORD_SAVE 0 >> ${CLIENT_NAME}-emb.ovpn 
    #echo auth-user-pass >> ${CLIENT_NAME}-emb.ovpn
    echo '<ca>' >> ${OVPN_DIR}/${CLIENT_NAME}-emb.ovpn
    cat ${CRT_CERT_DIR}/${CRT_CA_NAME}.pem >> ${OVPN_DIR}/${CLIENT_NAME}-emb.ovpn
    echo '</ca>' >> ${OVPN_DIR}/${CLIENT_NAME}-emb.ovpn
    echo '<cert>' >> ${OVPN_DIR}/${CLIENT_NAME}-emb.ovpn
    cat ${CRT_CERT_DIR}/${CLIENT_NAME}.crt >> ${OVPN_DIR}/${CLIENT_NAME}-emb.ovpn
    echo '</cert>' >> ${OVPN_DIR}/${CLIENT_NAME}-emb.ovpn
    echo '<key>' >> ${OVPN_DIR}/${CLIENT_NAME}-emb.ovpn
    cat ${CRT_CERT_DIR}/${CLIENT_NAME}.key >> ${OVPN_DIR}/${CLIENT_NAME}-emb.ovpn
    echo '</key>' >> ${OVPN_DIR}/${CLIENT_NAME}-emb.ovpn
    echo '<tls-auth>' >> ${OVPN_DIR}/${CLIENT_NAME}-emb.ovpn
    cat ${OVPN_TLSAUTH_KEY} >> ${OVPN_DIR}/${CLIENT_NAME}-emb.ovpn
    echo '</tls-auth>' >> ${OVPN_DIR}/${CLIENT_NAME}-emb.ovpn
echo " ---> Generate Openvpn file ${CLIENT_NAME}-file.ovpn"
    echo client > ${OVPN_DIR}/${CLIENT_NAME}-file.ovpn
    echo dev tun >> ${OVPN_DIR}/${CLIENT_NAME}-file.ovpn
    echo proto udp >> ${OVPN_DIR}/${CLIENT_NAME}-file.ovpn
    echo remote ${IP_ADDR} 1194 >> ${OVPN_DIR}/${CLIENT_NAME}-file.ovpn
    echo cipher AES-256-CBC >> ${OVPN_DIR}/${CLIENT_NAME}-file.ovpn
    echo auth SHA512 >> ${OVPN_DIR}/${CLIENT_NAME}-file.ovpn
    echo resolv-retry infinite >> ${OVPN_DIR}/${CLIENT_NAME}-file.ovpn
    echo redirect-gateway def1 >> ${OVPN_DIR}/${CLIENT_NAME}-file.ovpn
    echo nobind >> ${OVPN_DIR}/${CLIENT_NAME}-file.ovpn
    echo comp-lzo yes >> ${OVPN_DIR}/${CLIENT_NAME}-file.ovpn
    echo persist-key >> ${OVPN_DIR}/${CLIENT_NAME}-file.ovpn
    echo persist-tun >> ${OVPN_DIR}/${CLIENT_NAME}-file.ovpn
    echo persist-remote-ip >> ${OVPN_DIR}/${CLIENT_NAME}-file.ovpn
    echo user openvpn >> ${OVPN_DIR}/${CLIENT_NAME}-file.ovpn
    echo group openvpn >> ${OVPN_DIR}/${CLIENT_NAME}-file.ovpn
    echo verb 3 >> ${OVPN_DIR}/${CLIENT_NAME}-file.ovpn
    #echo setenv ALLOW_PASSWORD_SAVE 0 >> ${CLIENT_NAME}-file.ovpn 
    #echo auth-user-pass >> ${CLIENT_NAME}-file.ovpn
    echo 'ca {CRT_CA_NAME}.crt' >> ${OVPN_DIR}/${CLIENT_NAME}-file.ovpn
    echo 'cert ${CLIENT_NAME}.crt' >> ${OVPN_DIR}/${CLIENT_NAME}-file.ovpn
    echo 'key ${CLIENT_NAME}.key' >> ${OVPN_DIR}/${CLIENT_NAME}-file.ovpn
    echo 'tls-auth ta.key 1' >> ${OVPN_DIR}/${CLIENT_NAME}-file.ovpn
echo " ---> Generate Openvpn Config file "
    echo port 1194 >> ${OVPN_CONFIG}.conf
    echo proto udp >> ${OVPN_CONFIG}.conf
    echo dev tun >> ${OVPN_CONFIG}.conf
    echo ca /etc/certs/ca.crt >> ${OVPN_CONFIG}.conf
    echo cert /etc/certs/server.crt >> ${OVPN_CONFIG}.conf
    echo key /etc/certs/server.key >> ${OVPN_CONFIG}.conf
    echo dh /etc/certs/dh4096.pem >> ${OVPN_CONFIG}.conf
    echo tls-auth /etc/certs/ta.key 0 >> ${OVPN_CONFIG}.conf
    echo server 10.8.0.0 255.255.255.0 >> ${OVPN_CONFIG}.conf
    echo ifconfig-pool-persist ipp.txt >> ${OVPN_CONFIG}.conf #maintain record client/virtual IP
    echo client-to-client >> ${OVPN_CONFIG}.conf
    echo keepalive 10 120 >> ${OVPN_CONFIG}.conf
    echo cipher AES-256-CBC >> ${OVPN_CONFIG}.conf
    echo auth SHA512 >> ${OVPN_CONFIG}.conf
    echo persist-key >> ${OVPN_CONFIG}.conf
    echo persist-tun >> ${OVPN_CONFIG}.conf
    echo status openvpn-status.log >> ${OVPN_CONFIG}.conf
    echo verb 3 >> ${OVPN_CONFIG}.conf
    echo explicit-exit-notify 1 >> ${OVPN_CONFIG}.conf


/usr/sbin/openvpn --cd /etc/openvpn --config /etc/openvpn/openvpn.conf --script-security 2


exec "$@"
