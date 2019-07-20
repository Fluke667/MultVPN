#!/bin/sh
set -o errexit

echo " ---> Generate torrc Config File"
    echo User tord > ${TOR_CONF}
    echo Nickname MyName >> ${TOR_CONF}
    echo ContactInfo noreply@mymail.com >> ${TOR_CONF}
    echo DataDirectory /var/lib/tor >> ${TOR_CONF}
    echo ORPort 9001 >> ${TOR_CONF}
    echo #ORPort [IPv6-address]:9001 >> ${TOR_CONF}
    echo #DirPort 9030 >> ${TOR_CONF}
    echo ExitPolicy reject *:* >> ${TOR_CONF}
    echo ExitPolicy reject6 *:* >> ${TOR_CONF}
    echo SocksPort 9050 >> ${TOR_CONF}
    echo #ControlSocket 0 >> ${TOR_CONF}
    echo RelayBandwidthRate 1 MB >> ${TOR_CONF}
    echo RelayBandwidthBurst 1 MB >> ${TOR_CONF}
    echo AccountingMax 1 GBytes >> ${TOR_CONF}
    echo ControlPort 9051 >> ${TOR_CONF}
    echo HashedControlPassword $TOR_PASS >> ${TOR_CONF}
    echo #CookieAuthentication 1 >> ${TOR_CONF}
    echo #BridgeRelay 1 >> ${TOR_CONF}
    echo #PublishServerDescriptor 0 >> ${TOR_CONF}
echo " ---> Generate Torsocks Config File"
    echo TorAddress 127.0.0.1 > ${TOR_SOCKS}
    echo TorPort 9050 >> ${TOR_SOCKS}
    echo OnionAddrRange 127.42.42.0/24 >> ${TOR_SOCKS}
    echo SOCKS5Username $TORSOCKS_USERNAME >> ${TOR_SOCKS}
    echo SOCKS5Password $TORSOCKS_PASSWORD >> ${TOR_SOCKS}
    echo #AllowInbound 1 >> ${TOR_SOCKS}
    echo #AllowOutboundLocalhost 1 >> ${TOR_SOCKS}
    echo #IsolatePID 1 >> ${TOR_SOCKS}





chmodf() { find $2 -type f -exec chmod -v $1 {} \;
}
chmodd() { find $2 -type d -exec chmod -v $1 {} \;
}

echo -e "\n========================================================"
# If DataDirectory, identity keys or torrc is mounted here,
# ownership needs to be changed to the TOR_USER user
chown -Rv ${TOR_USER}:${TOR_USER} /var/lib/tor
# fix permissions
chmodd 700 /var/lib/tor
chmodf 600 /var/lib/tor

if [ ! -e /tor-config-done ]; then
    touch /tor-config-done   # only run this once

    # Add Nickname from env variable or randomized, if none has been set
    if ! grep -q '^Nickname ' /etc/tor/torrc; then
        if [ ${TOR_NICK} == "Tor4" ] || [ -z "${TOR_NICK}" ]; then
            # if user did not change the default Nickname, genetrate a random pronounceable one
            RPW=$(pwgen -0A 8)
            TOR_NICK="Tor4${RPW}"
            echo "Setting random Nickname: ${TOR_NICK}"
        else
            echo "Setting chosen Nickname: ${TOR_NICK}"
        fi
        echo -e "\nNickname ${TOR_NICK}" >> /etc/tor/torrc
    fi

    # Add TOR_EMAIL from env variable, if none has been set in torrc
    if ! grep -q '^ContactInfo ' /etc/tor/torrc; then
        # if TOR_EMAIL is not null
        if [ -n "${TOR_EMAIL}" ]; then
            echo "Setting Contact Email: ${TOR_EMAIL}"
            echo -e "\nContactInfo ${TOR_EMAIL}" >> /etc/tor/torrc
        fi
    fi
fi

echo -e "\n========================================================"
# Display OS version, Tor version & torrc in log
echo -e "Alpine Version: \c" && cat /etc/alpine-release
tor --version
obfs4proxy -version
cat /etc/tor/torrc
echo -e "========================================================\n"

# execute from user
USER ${TOR_USER}
echo SOCKSPort 0.0.0.0:9050 > torrc
exec tor --RunAsDaemon 0 -f torrc
