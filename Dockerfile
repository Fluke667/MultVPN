FROM alpine:3.9
ENV STRONGSWAN_RELEASE https://download.strongswan.org/strongswan.tar.bz2

RUN apk --update add build-base \
            ca-certificates \
            curl \
            curl-dev \
            ip6tables \
            iproute2 \
            iptables-dev \
	    pptpd \
	    xl2tpd \
            openssl \
            openssl-dev && \
    mkdir -p /tmp/strongswan && \
    curl -Lo /tmp/strongswan.tar.bz2 $STRONGSWAN_RELEASE && \
    tar --strip-components=1 -C /tmp/strongswan -xjf /tmp/strongswan.tar.bz2 && \
    cd /tmp/strongswan && \
    ./configure --prefix=/usr \
            --sysconfdir=/etc \
            --libexecdir=/usr/lib \
            --with-ipsecdir=/usr/lib/strongswan \
            --enable-aesni \
            --enable-chapoly \
            --enable-cmd \
            --enable-curl \
            --enable-dhcp \
            --enable-eap-dynamic \
            --enable-eap-identity \
            --enable-eap-md5 \
            --enable-eap-mschapv2 \
            --enable-eap-radius \
            --enable-eap-tls \
            --enable-eap-ttls \
            --enable-eap-tnc \
            --enable-eap-peap \
            --enable-farp \
            --enable-files \
            --enable-gcm \
            --enable-md4 \
            --enable-newhope \
            --enable-ntru \
            --enable-openssl \
            --enable-sha3 \
            --enable-shared \
            --enable-xauth-eap \
            --enable-md4 \
            --enable-af-alg \
            --enable-ccm \
            --enable-sqlite \
	    --enable-vici \
            --enable-python-eggs \
            --disable-aes \
            --disable-des \
            --disable-gmp \
            --disable-hmac \
            --disable-ikev1 \
            --disable-md5 \
            --disable-rc2 \
            --disable-sha1 \
            --disable-sha2 \
            --disable-static && \
    make && \
    make install && \
    rm -rf /tmp/* && \
    apk del build-base curl-dev openssl-dev && \
    rm -rf /var/cache/apk/*

### Expose Ports
# 1723/tcp+udp - PPTP Protocol    
# 500/udp  - Internet Key Exchange (IKE)   
# 4500/udp - IPSec NAT Traversal
# 1701/udp - Layer 2 Forwarding Protocol (L2F) & Layer 2 Tunneling Protocol (L2TP)
# 1515/tcp - Webinterface
EXPOSE 1723/tcp 1723/udp 500/udp 4500/udp 1701/udp 1515/tcp

ENTRYPOINT ["/usr/sbin/ipsec"]
CMD ["start", "--nofork"]
