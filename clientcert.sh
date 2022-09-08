#!/bin/sh

key_size=4096

clean() {
    rm -f *.crt *.key *.p12
}

create_ca() {
    openssl genrsa -out ca.key ${key_size}
    # https://datatracker.ietf.org/doc/html/rfc4519#section-2
    openssl req -new -x509 -key ca.key -out ca.crt -subj "/O=clientcert/CN=CA"
}

create_user() {
    username=$1

    openssl genrsa -out ${username}.key ${key_size}
    openssl req -new -key ${username}.key -out ${username}.csr -subj "/O=clientcert/CN=${username}"
	openssl x509 -req -in ${username}.csr -CA ca.crt -CAkey ca.key -set_serial $(date +%s) -days 1000 -out ${username}.crt
	rm ${username}.csr
	openssl pkcs12 -export -out ${username}.p12 -inkey ${username}.key -in ${username}.crt -certfile ca.crt # -password pass:''
}

usage() {
    echo "Usage: clientcert.sh (ca|user) [username]"
    echo "Example: "
    echo "    clientcert.sh ca"
    echo "    clientcert.sh user user1"
}

if [ "$1" == "ca" ];then
    clean
    create_ca
elif [ "$1" == "user" ] && [ "$2" ];then
    create_user "$2"
else
    usage
    exit 1
fi
