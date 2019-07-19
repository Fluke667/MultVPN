#!/bin/sh

  echo " ---> Generate External files *.ext"
    echo null > ${CRT_CA_EXT}
    echo basicConstraints = CA:FALSE >> ${CRT_SRV_EXT}
    echo subjectKeyIdentifier=hash >> ${CRT_SRV_EXT}
    echo authorityKeyIdentifier=keyid >> ${CRT_SRV_EXT}
    echo basicConstraints = critical,CA:true >> ${CRT_ISS_EXT}
    echo keyUsage = critical,keyCertSign >> ${CRT_ISS_EXT}
    echo basicConstraints = CA:FALSE >> ${CRT_CLI_EXT}
    echo subjectKeyIdentifier=hash >> ${CRT_CLI_EXT}
    echo authorityKeyIdentifier=keyid >> ${CRT_CLI_EXT}
    echo extendedKeyUsage = serverAuth,clientAuth >> ${CRT_PUB_EXT}
    echo subjectAltName = @alt_names >> ${CRT_PUB_EXT}
    echo [alt_names] >> ${CRT_PUB_EXT}

if [ ! -f "$CRT_CA.crt" ]
        then
        
echo " ---> Generate Root CA private key"
openssl genrsa -out ${CRT_CA}.key ${CRT_KEY_LENGTH} 
echo " ---> Generate Root CA certificate request"
openssl req -new -key ${CRT_CA}.key -out ${CRT_CA}.csr -subj $CRT_CA_SUBJ
echo " ---> Generate self-signed Root CA certificate"
openssl req -x509 -key ${CRT_CA}.key -in ${CRT_CA}.csr -out ${CRT_CA}.crt -days ${CRT_DAYS}
openssl req -x509 -key ${CRT_CA}.key -in ${CRT_CA}.csr -out ${CRT_CA}.pem -days ${CRT_DAYS}


#openssl genrsa -out ${CAname}.key ${CAkeyLength} 
#openssl req -x509 -new -nodes -key ${CAname}.key -sha256 -days ${CAexpire} -out ${CAname}.pem -subj $CAsubject

else
  echo "ENTRYPOINT: $CRT_CA.crt already exists"
fi



if [ ! -f "$CRT_SRV.crt" ]
        then
echo " ---> Generate SRV private key"
	openssl genrsa -out ${CRT_SRV}.key ${CRT_KEY_LENGTH}
echo " ---> Generate SRV certificate request"
	openssl req  -new -key ${CRT_SRV}.key -out ${CRT_SRV}.csr -subj ${CRT_SRV_SUBJ}
echo " ---> Generate SRV certificate"
	openssl x509 -req -extfile ${CRT_SRV_EXT} -in ${CRT_SRV}.csr -CA ${CRT_CA}.pem -CAkey ${CRT_CA}.key \
		     -CAcreateserial -out ${CRT_SRV}.crt -days ${CRT_DAYS} -sha256
		     
else
  echo "ENTRYPOINT: $CRT_SRV.crt already exists"
fi


if [ ! -f "$CRT_CLI.crt" ]
        then
echo " ---> Generate CLI private key"
	openssl genrsa -out ${CRT_CLI}.key ${CRT_KEY_LENGTH}
echo " ---> Generate CLI certificate request"
	openssl req  -new -key ${CRT_CLI}.key -out ${CRT_CLI}.csr -subj ${CRT_CLI_SUBJ}
echo " ---> Generate CLI certificate"
	openssl x509 -req -extfile ${CRT_CLI_EXT} -in ${CRT_CLI}.csr -CA ${CRT_CA}.pem -CAkey ${CRT_CA}.key \
		     -CAcreateserial -out ${CRT_CLI}.crt -days ${CRT_DAYS} -sha256
		     
else
  echo "ENTRYPOINT: $CRT_CLI.crt already exists"
fi


#if [ ! -f "$CRT_PUB.crt" ]
#        then
#echo " ---> Generate PUB private key"
#	openssl genrsa -out ${CRT_PUB}.key ${CRT_KEY_LENGTH}
#echo " ---> Generate PUB certificate request"
#	openssl req  -new -key ${CRT_PUB}.key -out ${CRT_PUB}.csr -subj ${CRT_PUB_SUBJ}
#echo " ---> Generate PUB certificate"
#	openssl x509 -req -extfile ${CRT_PUB_EXT} -in ${CRT_PUB}.csr -CA ${CRT_CA}.pem -CAkey ${CRT_CA}.key \
#		     -CAcreateserial -out ${CRT_PUB}.crt -days ${CRT_DAYS} -sha256
		     
#else
#  echo "ENTRYPOINT: $CRT_PUB.crt already exists"
#fi

echo " ---> Generate Diffie-Hellman Key"
echo " ---> Later turn ON ... Slow for Testing"
  #openssl dhparam \
  #  -out "$CRT_CERT_DIR/$CRT_DIFF_NAME-$CRT_DIFF_LENGTH.dh" $CRT_DIFF_LENGTH


if [ ! -f "$CRT_CERT_DIR/ca-comb.pem" ]
then
  # make combined root and issuer ca.pem
  echo " ---> Generate a combined root and issuer ca.pem"
  cat "$CRT_CERT_DIR/$CRT_CLI.crt" "$CRT_CERT_DIR/$CRT_CA.crt" > "$CRT_CERT_DIR/ca-comb.pem"
else
  echo "ENTRYPOINT: ca.pem already exists"
fi



if [ ! -f "$CRT_CERT_DIR/$CRT_KEYSTORE_NAME.pfx" ]
then
  # make PKCS12 keystore
  echo " ---> Generate $CRT_KEYSTORE_NAME.pfx"
  openssl pkcs12 \
    -export \
    -in "$CRT_CERT_DIR/$CRT_PUB.crt" \
    -inkey "$CRT_CERT_DIR/$CRT_PUB.key" \
    -certfile "$CRT_CERT_DIR/ca.pem" \
    -password "pass:$CRT_KEYSTORE_PASS" \
    -out "$CRT_CERT_DIR/$CRT_KEYSTORE_NAME.pfx"
else
  echo "ENTRYPOINT: $CRT_KEYSTORE_NAME.pfx already exists"
fi
