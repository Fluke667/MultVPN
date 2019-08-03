#!/bin/sh

#sslh -f -u sslh --listen $SSLH --ssh $SSLH_SSH --tls $SSLH_TLS --ovpn $SSLH_OVPN --tinc $SSLH_TINC --ssocks $SSLH_SSOCKS --any $SSLH_ANY &
#ss-local -s $PRV_SERVER -p $PRV_SERVER_PORT -b $PRV_LOCAL -l $PRV_LOCAL_PORT -k $PRV_PASS -m $PRV_METHOLD -d start -c $PRV_CONF &
#/opt/i2pd/bin/i2pd --http.enabled=1 --http.address=0.0.0.0 --http.port=8080 --httpproxy.enabled=1 --httpproxy.address=0.0.0.0 --httpproxy.port=4444
#i2pd --nat=true --service --http.enabled=true --http.address=0.0.0.0 --httpproxy.enabled=true --httpproxy.address=0.0.0.0 --socksproxy.enabled=true --socksproxy.address=0.0.0.0 --sam.enabled=true --sam.address=0.0.0.0 &
#tinc --net=$NETWORK start --no-detach --debug=$DEBUG --logfile=/var/log/tinc/tinc.$NETWORK.log
#exec ss-server -v -s ${SS_SERVER_ADDR} -p ${SS_SERVER_PORT} -l ${SS_LOCAL_PORT} -k ${SS_PASSWORD} -t ${SS_TIMEOUT} -m ${SS_METHOD} -n ${SS_MAXOPENFILES} -d ${SS_DNS} --fast-open --reuse-port -u 
#exec ss-local -u --fast-open -c /etc/shadowsocks-libev/privoxy.json
#ss-tunnel -c /etc/shadowsocks-libev/sstunnel_tor.json &


pproxy -l socks4+socks5://:8090#$PPROXY_USER:$PPROXY_PASS &
pproxy -l http://:8080#$PPROXY_USER:$PPROXY_PASS &
pproxy -l ss://aes-256-gcm:yDRHHo1PjnolIVQHF3H4cpuL45udo7aHOco+Og==@:8070 &
openvpn --writepid /run/openvpn/ovpn.pid --cd /etc/openvpn --config /etc/openvpn/openvpn.conf &
proxybroker serve --host 0.0.0.0 --port 8888 --types HTTP HTTPS --lvl High &
tinc --net=$TINC_NETNAME start -D --config=$TINC_DIR/$TINC_NETNAME -D --debug=$TINC_DEBUG --logfile=$TINC_LOG &
ss-server -c /etc/shadowsocks-libev/standalone.json &
tor --RunAsDaemon 0 -f /etc/tor/torrc



$@
      
      
        



