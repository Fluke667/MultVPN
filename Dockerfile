FROM alpine:3.9
MAINTAINER Fluke667 <Fluke667@gmail.com>  
ARG TZ='Europe/Berlin'
ENV TZ ${TZ}

RUN wget -P /etc/apk/keys https://alpine-repo.sourceforge.io/DDoSolitary@gmail.com-00000000.rsa.pub
RUN apk add --no-cache -X https://alpine-repo.sourceforge.io/packages

RUN apk update \
    && apk add --no-cache --virtual build-dependencies \
    libev-dev libsodium-dev mbedtls-dev pcre-dev iptables-dev sqlite-dev musl-dev xz-dev \
    openssl-dev curl-dev python3-dev libtool c-ares-dev zlib-dev libffi-dev libconfig-dev \
    build-base gcc g++ git autoconf automake make wget linux-headers
	
RUN apk upgrade \
    && apk add --no-cache \
        bash \
	tzdata \
	rng-tools \
	gnupg \
	runit \
        curl \
	nano \
	go \
        libtool \
        tar \
	python3 py3-setuptools py3-cryptography \
	libffi\
	nodejs npm \
        ca-certificates \
        iptables ip6tables iproute2 \
	pptpd \
	xl2tpd \
	sqlite sqlite-libs \
        openssl \
	openssh \
        strongswan \
	libsodium \
	libconfig \
	bzip2 \
	libbz2 \
	expat \
	gdbm \
	xz \
	dcron \
	stunnel \
	gnupg \
	libressl \
	readline \
    rm -rf /tmp/* \
    rm -rf /var/cache/apk/*
    
RUN mkdir -p /var/log/cron && mkdir -m 0644 -p /var/spool/cron/crontabs && touch /var/log/cron/cron.log && mkdir -m 0644 -p /etc/cron.d
    
RUN apk update --no-cache --allow-untrusted --repository http://dl-4.alpinelinux.org/alpine/edge/testing/ \
      && apk add --no-cache sslh \
      rm -rf /var/cache/apk/* \
      /tmp/* \
     /var/tmp/*
    
    
RUN python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --upgrade pip setuptools && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
    if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
    rm -r /root/.cache && \
    pip3 install --no-cache --upgrade \
    wheel asn1crypto asyncssh cffi pycparser pycryptodome six pproxy


### Expose Ports
# 1723/tcp+udp - PPTP Protocol    
# 500/udp  - Internet Key Exchange (IKE)   
# 4500/udp - IPSec NAT Traversal
# 1701/udp - Layer 2 Forwarding Protocol (L2F) & Layer 2 Tunneling Protocol (L2TP)
# 1515/tcp - Webinterface
# 8388/tcp 8388/udp - shadowsocks-libev Ports
# 8010/tcp 8020/tcp 8030/tcp 8040/tcp - Ports for pproxy
EXPOSE 1723/tcp 1723/udp 500/udp 4500/udp 1701/udp 1515/tcp 8388/tcp 8388/udp 8010/tcp 8020/tcp 8030/tcp 8040/tcp



# PPTP Configuration
COPY ./etc/pptpd.conf /etc/pptpd.conf   
COPY ./etc/ppp/pptpd-options /etc/ppp/pptpd-options  
# Strongswan Configuration  
COPY ./etc/ipsec.conf /etc/ipsec.conf   
COPY ./etc/strongswan.conf /etc/strongswan.conf 
COPY ./etc/strongswan.d/charon.conf /etc/strongswan.d/charon.conf
# L2TP Configuration  
COPY ./etc/xl2tpd/xl2tpd.conf /etc/xl2tpd/xl2tpd.conf
COPY ./etc/ppp/options.xl2tpd /etc/ppp/options.xl2tpd 
# Copy Scripts 
COPY ./scripts/* /usr/local/bin/
RUN ls -al /usr/local/bin/

ADD ./config /config
RUN chmod 0700 /config/*.sh
RUN /config/auth.sh \
    /config/cert.sh \
    /config/firewall.sh \
    /config/pproxy.sh \
    /config/sslh.sh \
    /config/stunnel.sh

VOLUME ["/data/multivpn/pproxy"]
VOLUME ["/data/multivpn/ppp"]
VOLUME ["/data/multivpn/ipsec.d"]
VOLUME ["/data/multivpn/stunnel"]
VOLUME ["/data/multivpn/strongswan.d"]
VOLUME ["/data/multivpn/xltpd"]
VOLUME ["/data/multivpn/crond"]




CMD ["start", "--nofork"]
ENTRYPOINT ["/usr/sbin/ipsec"]

