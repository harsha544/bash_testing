#!/bin/bash

NOP=$1

##########################################################
# Updating crypto-config.yaml File
##########################################################

echo "# ---------------------------------------------------------------------------
# "OrdererOrgs" - Definition of organizations managing orderer nodes
# ---------------------------------------------------------------------------
OrdererOrgs:
  # ---------------------------------------------------------------------------
  # Orderer
  # ---------------------------------------------------------------------------
  - Name: Orderer
    Domain: example.com
    # ---------------------------------------------------------------------------
    # "Specs" - See PeerOrgs below for complete description
    # ---------------------------------------------------------------------------
    Specs:
      - Hostname: orderer
# ---------------------------------------------------------------------------
# "PeerOrgs" - Definition of organizations managing peer nodes
# ---------------------------------------------------------------------------
PeerOrgs:" >> crypto-config.yaml
  for ((i=1; i<=$NOP; i++))
  do
	echo "  # ---------------------------------------------------------------------------" >> crypto-config.yaml
	echo "  # Org$i: See "Org$i" for full specification" >> crypto-config.yaml
	echo "  # ---------------------------------------------------------------------------" >> crypto-config.yaml	
	echo "  - Name: Org$i" >> crypto-config.yaml
	echo "    Domain: org$i.example.com" >> crypto-config.yaml
	echo "    Template:" >> crypto-config.yaml
	echo "      Count: 2" >> crypto-config.yaml
	echo "    Users:" >> crypto-config.yaml
	echo "      Count: 1"   >> crypto-config.yaml
  done 
  # popd


##########################################################
# Updating configtx.yaml File
##########################################################


# cp profile_configtx.yaml configtx.yaml

echo "---
################################################################################
#
#   Profile
#
#   - Different configuration profiles may be encoded here to be specified
#   as parameters to the configtxgen tool
#
################################################################################
Profiles:

    OrgsOrdererGenesis:
        Orderer:
            <<: *OrdererDefaults
            Organizations:
                - *OrdererOrg
        Consortiums:
            SampleConsortium:" >> configtx.yaml

# Updating Profiles Section
for ((i=1; i<=$NOP; i++))
do
	echo "                    - *Org$i" >> configtx.yaml
done

# Continue Updating Profiles Section

echo "    OrgsChannel:" >> configtx.yaml
echo "        Consortium: SampleConsortium" >> configtx.yaml
echo "        Application:" >> configtx.yaml
echo "            <<: *ApplicationDefaults" >> configtx.yaml
echo "            Organizations:" >> configtx.yaml

for ((i=1; i<=$NOP; i++))
do
        echo "                    - *Org$i" >> configtx.yaml
done

##########################################################
# Updating Organizations Section
##########################################################

echo "################################################################################" >> configtx.yaml
echo "#" >> configtx.yaml
echo "#   Section: Organizations" >> configtx.yaml
echo "#" >> configtx.yaml
echo "#   - This section defines the different organizational identities which will" >> configtx.yaml
echo "#   be referenced later in the configuration." >> configtx.yaml
echo "#" >> configtx.yaml
echo "################################################################################" >> configtx.yaml

echo "Organizations:" >> configtx.yaml
echo "    - &OrdererOrg" >> configtx.yaml
echo "        Name: OrdererOrg" >> configtx.yaml
echo "        ID: OrdererMSP" >> configtx.yaml
echo "        MSPDir: crypto-config/ordererOrganizations/example.com/msp" >> configtx.yaml
echo "        AdminPrincipal: Role.MEMBER" >> configtx.yaml

for ((i=1; i<=$NOP; i++))
do
	echo "    - &Org$i" >> configtx.yaml
	echo "        Name: Org"$i"MSP" >> configtx.yaml
	echo "        ID: Org"$i"MSP" >> configtx.yaml
	echo "        MSPDir: crypto-config/peerOrganizations/org$i.example.com/msp" >> configtx.yaml
	echo "        AdminPrincipal: Role.MEMBER" >> configtx.yaml
	echo "        AnchorPeers:" >> configtx.yaml
	echo "            - Host: blockchain-org"$i"peer1" >> configtx.yaml
	echo "              Port: 30"$i"10" >> configtx.yaml
done


##########################################################
# Updating Orderer Section
##########################################################

echo "################################################################################"  >> configtx.yaml
echo "#" >> configtx.yaml
echo "#   SECTION: Orderer" >> configtx.yaml
echo "#" >> configtx.yaml
echo "#   - This section defines the values to encode into a config transaction or" >> configtx.yaml
echo "#   genesis block for orderer related parameters" >> configtx.yaml
echo "#" >> configtx.yaml
echo "################################################################################" >> configtx.yaml

echo "Orderer: &OrdererDefaults" >> configtx.yaml
echo "    OrdererType: solo" >> configtx.yaml
echo "    Addresses:" >> configtx.yaml
echo "        - blockchain-orderer:31010" >> configtx.yaml
echo "    BatchTimeout: 2s" >> configtx.yaml
echo "    BatchSize:" >> configtx.yaml
echo "        MaxMessageCount: 10" >> configtx.yaml
echo "        AbsoluteMaxBytes: 99 MB" >> configtx.yaml
echo "        PreferredMaxBytes: 512 KB" >> configtx.yaml
echo "    Kafka:" >> configtx.yaml
echo "        Brokers:" >> configtx.yaml
echo "            - 127.0.0.1:9092" >> configtx.yaml
echo "    Organizations:" >> configtx.yaml

##########################################################
# Updating Application Section
##########################################################

echo "################################################################################" >> configtx.yaml
echo "#" >> configtx.yaml
echo "#   SECTION: Application" >> configtx.yaml
echo "#" >> configtx.yaml
echo "#   - This section defines the values to encode into a config transaction or" >> configtx.yaml
echo "#   genesis block for application related parameters" >> configtx.yaml
echo "#" >> configtx.yaml
echo "################################################################################" >> configtx.yaml

echo "Application: &ApplicationDefaults" >> configtx.yaml
echo "    Organizations:" >> configtx.yaml

##########################################################
# Updating service/definition files specific to Peer
##########################################################

#pushd ../helm-charts/ibm-blockchain-network/templates/

#popd

for ((i=1; i<=$NOP; i++))
do
echo "
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: {{ template "ibm-blockchain-network.fullname" . }}-org"$i"peer1
  labels:
    app: {{ template "ibm-blockchain-network.name" . }}
    chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
    release: {{ .Release.Name }}
    heritage: {{ .Release.Service }}
spec:
  replicas: 1
  template:
    metadata:
      name: {{ template "ibm-blockchain-network.fullname" . }}-org"$i"peer1
      labels:
        app: {{ template "ibm-blockchain-network.name" . }}
        chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
        release: {{ .Release.Name }}
        heritage: {{ .Release.Service }}
        name: {{ template "ibm-blockchain-network.fullname" . }}-org"$i"peer1
    spec:
      volumes:
      - name: {{ template "ibm-blockchain-shared-pvc.name" . }}
        persistentVolumeClaim:
         claimName: {{ template "ibm-blockchain-shared-pvc.name" . }}
      - name: dockersocket
        hostPath:
          path: /var/run/docker.sock

      containers:
      - name: org"$i"peer1
        image: {{ .Values.blockchain.peerImage }}
        imagePullPolicy: {{ .Values.blockchain.pullPolicy }}
        command:
          - sh
          - -c
          - |
            sleep 1

            while [ ! -f /shared/bootstrapped ]; do
              echo Waiting for bootstrap
              sleep 1
            done

            touch /shared/status_org"$i"peer1_complete &&
            peer node start --peer-defaultchain=false
        env:
        - name: CORE_PEER_ADDRESSAUTODETECT
          value: "true"
        - name: CORE_PEER_NETWORKID
          value: nid1
        - name: CORE_PEER_ADDRESS
          value: {{ template "ibm-blockchain-network.name" . }}-org"$i"peer1:5010
        - name: CORE_PEER_LISTENADDRESS
          value: 0.0.0.0:5010
        - name: CORE_PEER_EVENTS_ADDRESS
          value: 0.0.0.0:5011
        - name: CORE_PEER_COMMITTER_ENABLED
          value: "true"
        - name: CORE_PEER_PROFILE_ENABLED
          value: "true"
        - name: CORE_PEER_DISCOVERY_PERIOD
          value: 60s
        - name: CORE_PEER_DISCOVERY_TOUCHPERIOD
          value: 60s
        - name: CORE_VM_ENDPOINT
          value: unix:///host/var/run/docker.sock
        - name: CORE_PEER_LOCALMSPID
          value: Org2MSP
        - name: CORE_PEER_MSPCONFIGPATH
          value: /shared/crypto-config/peerOrganizations/org"$i".example.com/peers/peer0.org"$i".example.com/msp/
        - name: CORE_LOGGING_LEVEL
          value: debug
        - name: CORE_LOGGING_PEER
          value: debug
        - name: CORE_LOGGING_CAUTHDSL
          value: debug
        - name: CORE_LOGGING_GOSSIP
          value: debug
        - name: CORE_LOGGING_LEDGER
          value: debug
        - name: CORE_LOGGING_MSP
          value: debug
        - name: CORE_LOGGING_POLICIES
          value: debug
        - name: CORE_LOGGING_GRPC
          value: debug
        - name: CORE_PEER_ID
          value: org"$i"peer1
        - name: CORE_PEER_TLS_ENABLED
          value: "false"
        - name: CORE_LEDGER_STATE_STATEDATABASE
          value: goleveldb
        - name: PEER_CFG_PATH
          value: peer_config/
        - name: FABRIC_CFG_PATH
          value: /etc/hyperledger/fabric/
        - name: ORDERER_URL
          value: {{ template "ibm-blockchain-network.name" . }}-orderer:31010
        - name: GODEBUG
          value: "netdns=go"
        volumeMounts:
        - mountPath: /shared
          name: {{ template "ibm-blockchain-shared-pvc.name" . }}
        - mountPath: /host/var/run/docker.sock
          name: dockersocket
" >> blockchain-org"$i"peer1.yaml

done

#popd


for ((i=1; i<=$NOP; i++))
do

echo "---
apiVersion: v1
kind: Service
metadata:
  name: {{ template "ibm-blockchain-network.name" . }}-org"$i"peer1
  labels:
    app: {{ template "ibm-blockchain-network.name" . }}
    chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
    release: {{ .Release.Name }}
    heritage: {{ .Release.Service }}
    run: {{ template "ibm-blockchain-network.name" . }}-org"$i"peer1
spec:
  type: NodePort
  selector:
    name: {{ template "ibm-blockchain-network.name" . }}-org"$i"peer1
    app: {{ template "ibm-blockchain-network.name" . }}
    release: {{ .Release.Name }}
  ports:
  - protocol: TCP
    port: 5010
    nodePort: 30"$i"10
    name: grpc
  - protocol: TCP
    port: 5011
    nodePort: 30"$i"11
    name: events
" >> blockchain-org"$i"peer1-service.yaml

done
