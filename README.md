---------------------
##This explains how to modify organization names, Adding More organizations and adding couch db as state database.

---------------------------------
Purpose: Change the naming convention of entities

	peer0.org1.example.com to peer0.patient.com
	peer1.org1.example.com to peer1.patient.com
	
	peer0.org2.example.com to peer0.hospital.com
	peer1.org2.example.com to peer1.hospital.com
	
	ca.org1.example.com to ca.patient.com
	ca.org2.example.com to ca.hospital.com

Add below organizations

	ca.lab.com
	ca.government.com
	peer0.lab.com
	peer1.lab.com
	peer0.government.com
	peer1.government.com
	couchdb for each peer

---------------------------------




**1. Move to below location** 

home/seeraj/blockchain/fabric-samples/balance-transfer/artifacts/channel/cryptogen.yaml

Modify the **cryptogen.yaml **file based on required naming convention perform the changes

--------------------------------

**2. Changes to 'docker-compose.yaml'**

run below command 

/home/seeraj/blockchain/fabric-samples/bin/cryptogen generate --config=./cryptogen.yaml


peer0.org1.example.com to patient.peer0.com:

	container_name
	CORE_PEER_ID
	CORE_PEER_ADDRESS
	CORE_PEER_GOSSIP_EXTERNALENDPOINT

In other containers:

	CORE_PEER_GOSSIP_BOOTSTRAP

--------------------------------
**3. change to 'network-config.yaml'**

peers:

      peer0.org1.example.com to patient.peer0.com:

organizations:

	    peers:
			- peer0.org1.example.com to patient.peer0.com:
Peer:

	peer0.org1.example.com to patient.peer0.com:
		grpcOptions:
		  ssl-target-name-override: peer0.org1.example.com to  patient.peer0.com

------------------------------


**4. Generate configtxgen**

As we have changed the names, we need to re-create the genesis and channel files, so that the new naming convention can be used by the network while interacting
	
Go to below location

/home/seeraj/blockchain/fabric-samples/balance-transfer/artifacts/channel/configtx.yaml

AnchorPeers:

		- Host: peer0.org1.example.com to patient.peer0.com

Use below command to consider current path to consider for configtx.yml

	export FABRIC_CFG_PATH=$PWD
	
Re Generate genesis block

	/home/seeraj/blockchain/fabric-samples/bin/configtxgen -profile TwoOrgsOrdererGenesis -outputBlock ./genesis.block
	
regenerate channel.tx

	export CHANNEL_NAME=mychannel  && /home/seeraj/blockchain/fabric-samples/bin/configtxgen -profile TwoOrgsChannel -outputCreateChannelTx mychannel.tx -channelID $CHANNEL_NAME

----------------------------------

Replace all references in the testAPIs.sh files

	peer0.org1.example.com to patient.peer0.com:

-------------------------------

**5. Using Couch DB**

Needs to create couchdb entery for each of the peer in the 'docker-compose.yaml'
	
couchdb0:

    container_name: couchdb0
    image: hyperledger/fabric-couchdb
    # Populate the COUCHDB_USER and COUCHDB_PASSWORD to set an admin user and password
    # for CouchDB.  This will prevent CouchDB from operating in an "Admin Party" mode.
    environment:
      - COUCHDB_USER=
      - COUCHDB_PASSWORD=
    ports:
      - 5984:5984
	  
	
update/insert below lines in each peer

	  - CORE_LEDGER_STATE_STATEDATABASE=CouchDB
	  - CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS=couchdb0:5984
      - CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME=
      - CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD=

update/insert below line in each peer

	depends_on:
      - orderer.example.com
      - couchdb0 #usually this does not exists, you need to enter this
      
------------------------------------
    
While enrolling the Org3 and Or4 users system throws some random errors, to avoid this you need to commnet the affiliation and hardcord with Org1 in the 'Helper.JS'
	
	//affiliation: userOrg.toLowerCase() + 'Org1.department1'
	affiliation: 'org1.department1'



