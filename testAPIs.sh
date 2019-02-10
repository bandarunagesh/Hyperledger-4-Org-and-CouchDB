#!/bin/bash
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

jq --version > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "Please Install 'jq' https://stedolan.github.io/jq/ to execute this script"
	echo
	exit 1
fi

starttime=$(date +%s)

# Print the usage message
function printHelp () {
  echo "Usage: "
  echo "  ./testAPIs.sh -l golang|node"
  echo "    -l <language> - chaincode language (defaults to \"golang\")"
}
# Language defaults to "golang"
LANGUAGE="golang"

# Parse commandline args
while getopts "h?l:" opt; do
  case "$opt" in
    h|\?)
      printHelp
      exit 0
    ;;
    l)  LANGUAGE=$OPTARG
    ;;
  esac
done

##set chaincode path
function setChaincodePath(){
	LANGUAGE=`echo "$LANGUAGE" | tr '[:upper:]' '[:lower:]'`
	case "$LANGUAGE" in
		"golang")
		CC_SRC_PATH="github.com/example_cc/go"
		;;
		"node")
		CC_SRC_PATH="$PWD/artifacts/src/github.com/example_cc/node"
                CC_SRC_PATH_N="$PWD/artifacts/src/github.com/patient/node"
		;;
		*) printf "\n ------ Language $LANGUAGE is not supported yet ------\n"$
		exit 1
	esac
}

setChaincodePath

echo "POST request Enroll on Org1  ..."
echo
ORG1_TOKEN=$(curl -s -X POST \
  http://localhost:8080/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=Jim&orgName=Org1')
echo $ORG1_TOKEN
ORG1_TOKEN=$(echo $ORG1_TOKEN | jq ".token" | sed "s/\"//g")
echo
echo "ORG1 token is $ORG1_TOKEN"
echo
echo "POST request Enroll on Org2 ..."
echo
ORG2_TOKEN=$(curl -s -X POST \
  http://localhost:8080/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=Barry&orgName=Org2')
echo $ORG2_TOKEN
ORG2_TOKEN=$(echo $ORG2_TOKEN | jq ".token" | sed "s/\"//g")
echo
echo "ORG2 token is $ORG2_TOKEN"

echo "POST request Enroll on Org3 ..."
echo
ORG3_TOKEN=$(curl -s -X POST \
  http://localhost:8080/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=nagesh&orgName=Org3')
echo $ORG3_TOKEN
ORG3_TOKEN=$(echo $ORG3_TOKEN | jq ".token" | sed "s/\"//g")
echo
echo "ORG3 token is $ORG3_TOKEN"

echo "POST request Enroll on Org4 ..."
echo
ORG4_TOKEN=$(curl -s -X POST \
  http://localhost:8080/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=raju&orgName=Org4')
echo $ORG4_TOKEN
ORG4_TOKEN=$(echo $ORG4_TOKEN | jq ".token" | sed "s/\"//g")
echo
echo "ORG4 token is $ORG4_TOKEN"

echo
echo
echo "POST request Create channel  ..."
echo
curl -s -X POST \
  http://localhost:8080/channels \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"channelName":"mychannel",
	"channelConfigPath":"../artifacts/channel/mychannel.tx"
}'
echo
echo
sleep 5
echo "POST request Join channel on Org1"
echo
curl -s -X POST \
  http://localhost:8080/channels/mychannel/peers \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.patient.com","peer1.patient.com"]
}'
echo
echo

echo "POST request Join channel on Org2"
echo
curl -s -X POST \
  http://localhost:8080/channels/mychannel/peers \
  -H "authorization: Bearer $ORG2_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.hospital.com","peer1.hospital.com"]
}'
echo
echo


echo "POST request Join channel on Org3"
echo
curl -s -X POST \
  http://localhost:8080/channels/mychannel/peers \
  -H "authorization: Bearer $ORG3_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.lab.com","peer1.lab.com"]
}'
echo
echo

echo "POST request Join channel on Org4"
echo
curl -s -X POST \
  http://localhost:8080/channels/mychannel/peers \
  -H "authorization: Bearer $ORG4_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.government.com","peer1.government.com"]
}'
echo
echo



echo "POST Install chaincode Patient on Org1"
echo
curl -s -X POST \
  http://localhost:8080/chaincodes \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.patient.com\",\"peer1.patient.com\"],
	\"chaincodeName\":\"patient\",
	\"chaincodePath\":\"$CC_SRC_PATH_N\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"chaincodeVersion\":\"v0\"
}"
echo
echo




echo "POST Install chaincode Patient on Org2"
echo
curl -s -X POST \
  http://localhost:8080/chaincodes \
  -H "authorization: Bearer $ORG2_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.hospital.com\",\"peer1.hospital.com\"],
	\"chaincodeName\":\"patient\",
	\"chaincodePath\":\"$CC_SRC_PATH_N\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"chaincodeVersion\":\"v0\"
}"
echo
echo




echo "POST Install chaincode Patient on Org3"
echo
curl -s -X POST \
  http://localhost:8080/chaincodes \
  -H "authorization: Bearer $ORG3_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.lab.com\",\"peer1.lab.com\"],
	\"chaincodeName\":\"patient\",
	\"chaincodePath\":\"$CC_SRC_PATH_N\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"chaincodeVersion\":\"v0\"
}"
echo
echo



echo "POST Install chaincode Patient on Org4"
echo
curl -s -X POST \
  http://localhost:8080/chaincodes \
  -H "authorization: Bearer $ORG4_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.government.com\",\"peer1.government.com\"],
	\"chaincodeName\":\"patient\",
	\"chaincodePath\":\"$CC_SRC_PATH_N\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"chaincodeVersion\":\"v0\"
}"
echo
echo



echo "POST instantiate chaincode patient on Org1"
echo
curl -s -X POST \
  http://localhost:8080/channels/mychannel/chaincodes \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"chaincodeName\":\"patient\",
	\"chaincodeVersion\":\"v0\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"args\":[\"a\",\"100\",\"b\",\"200\"]

}"
echo
echo



echo "POST invoke chaincode patient on peers of Org1 and Org2"
echo
TRX_ID_N=$(curl -s -X POST \
  http://localhost:8080/channels/mychannel/chaincodes/patient \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.patient.com","peer0.hospital.com","peer0.lab.com","peer0.government.com"],
	"fcn":"initPatient",
	"args":["1234","provider1","nagesh","bandaru","nagesh@outlook.com","11-10-1985","11111","44444"]
}')
echo "Transaction ID is $TRX_ID_N"
echo
echo


echo "POST invoke chaincode patient on peers of Org1 and Org2"
echo
TRX_ID_N=$(curl -s -X POST \
  http://localhost:8080/channels/mychannel/chaincodes/patient \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.patient.com","peer0.hospital.com","peer0.lab.com","peer0.government.com"],
	"fcn":"updateProvider",
	"args":["1234","provider2"]
}')
echo "Transaction ID is $TRX_ID_N"
echo
echo



echo "GET query chaincode patient on peer1 of Org1"
echo
curl -s -X GET \
  "http://localhost:8080/channels/mychannel/chaincodes/patient?peer=peer0.patient.com&fcn=readPatient&args=%5B%221234%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo



echo "GET query Transaction by TransactionID"
echo
curl -s -X GET http://localhost:8080/channels/mychannel/transactions/$TRX_ID_N?peer=peer0.patient.com \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo



############################################################################
### TODO: What to pass to fetch the Block information
############################################################################
#echo "GET query Block by Hash"
#echo
#hash=????
#curl -s -X GET \
#  "http://localhost:8080/channels/mychannel/blocks?hash=$hash&peer=peer1" \
#  -H "authorization: Bearer $ORG1_TOKEN" \
#  -H "cache-control: no-cache" \
#  -H "content-type: application/json" \
#  -H "x-access-token: $ORG1_TOKEN"
#echo
#echo

echo "GET query ChainInfo"
echo
curl -s -X GET \
  "http://localhost:8080/channels/mychannel?peer=peer0.patient.com" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo

echo "GET query Installed chaincodes"
echo
curl -s -X GET \
  "http://localhost:8080/chaincodes?peer=peer0.patient.com" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo

echo "GET query Instantiated chaincodes"
echo
curl -s -X GET \
  "http://localhost:8080/channels/mychannel/chaincodes?peer=peer0.patient.com" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo

echo "GET query Channels"
echo
curl -s -X GET \
  "http://localhost:8080/channels?peer=peer0.patient.com" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo


echo "Total execution time : $(($(date +%s)-starttime)) secs ..."
