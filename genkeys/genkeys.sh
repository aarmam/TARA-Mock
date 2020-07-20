#!/bin/bash

RED='\033[0;31m'
NC='\033[0m'

echo -e "${RED}--- genkeys.sh"
echo -e "    Skript moodustab TARA-Mock tööks vajalikud võtmed ja serdid."
echo -e "    Vt: https://github.com/e-gov/TARA-Mock/blob/master/docs/Turvalisus.md"

echo -e " "
echo -e "--- NB! subj väärtustes tuleb Git for Windows kasutamisel seada"
echo -e "    tee-eraldajad: //CN\ ..."

echo -e " "
echo -e "--- 1 Valmistan CA võtme ja serdi${NC}"
openssl req \
  -new \
  -x509 \
  -newkey rsa:2048 \
  -keyout root_ca.key \
  -out root_ca.pem \
  -nodes \
  -days 1024 \
  -subj "/C=EE/ST=/L=/O=TEST-CA/CN=TEST-CA"

# Kuva subject ja issuer
echo -e "${RED}--- Valmistatud CA sert:${NC}"
openssl x509 \
  -in root_ca.pem \
  -noout \
  -subject -issuer

echo -e "${RED} "
echo -e "--- 2 Valmistan TARA-Mock HTTPS privaatvõtme ja serdi${NC}"
# Serditaotlus
openssl req \
  -new \
  -sha256 \
  -nodes \
  -out https.crs \
  -newkey rsa:2048 \
  -keyout https.key \
  -subj "/C=EE/ST=/L=/O=Arendaja/CN=Arendaja"
# Sert
openssl x509 \
  -req \
  -in https.crs \
  -CA root_ca.pem \
  -CAkey root_ca.key \
  -CAcreateserial \
  -out https.crt \
  -days 500 \
  -sha256 \
  -extfile v3.ext

# Kuva subject ja issuer
echo -e "${RED} "
echo -e "--- Valmistatud sert:${NC}"
openssl x509 \
  -in https.crt \
  -noout \
  -subject -issuer

echo -e "${RED} "
echo -e "--- 3 Genereerin identsustõendi allkirjastamise privaa t- ja avaliku võtme${NC}"
openssl genrsa \
  -out id_token_issuer.key \
  2048
openssl rsa \
  -in id_token_issuer.key \
  -pubout > id_token_issuer.pub

echo -e "${RED} "
echo -e "--- 4 Eemaldan vanad võtmed ja serdid${NC}"
rm -f /generated/service/*.*
rm -f /generated/client/*.*

echo -e "${RED} "
echo -e "--- 5 Paigaldan võtmed ja serdid TARA-Mock-i${NC}"
mkdir -p generated/service
cp root_ca.pem generated/service
cp https.key generated/service
cp https.crt generated/service
cp id_token_issuer.key generated/service
cp id_token_issuer.pub generated/service

echo -e "${RED} "
echo -e "--- 6 Paigaldan võtmed ja serdid klientrakendusse${NC}"
mkdir -p generated/client
cp root_ca.pem generated/client
cp https.key generated/client
cp https.crt generated/client

echo -e "${RED}--- Võtmed ja serdid genereeritud ja paigaldatud"
echo -e "--- Ära unusta sirvikusse usaldusankrut paigaldada${NC}"

# -------------------
# Abiteave
# These work for application/json, but not for text/html in browser
# openssl genrsa -out https.key 2048
# openssl ecparam -genkey -name secp384r1 -out https.key
# openssl req -new -x509 -sha256 -key https.key -out https.crt -days 3650

# Oluline allikas: https://www.freecodecamp.org/news/how-to-get-https-working-on-your-local-development-environment-in-5-minutes-7af615770eec/

# Windows-specific
# https://stackoverflow.com/questions/31506158/running-openssl-from-a-bash-script-on-windows-subject-does-not-start-with
# https://stackoverflow.com/questions/7360602/openssl-and-error-in-reading-openssl-conf-file
# set OPENSSL_CONF=c:/libs/openssl-0.9.8k/openssl.cnf
# echo %OPENSSL_CONF%
# echo
