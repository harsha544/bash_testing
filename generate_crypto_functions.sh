#!/bin/bash
#set -x

NOP=$1

if [ $NOP -gt 2 ]
then
  echo "Updating Crypto Material"
  # pushd ../sampleconfig/
  cp crypto-config.yaml.orig crypto-config.yaml
  for ((i=3; i<=$NOP; i++))
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
else
  NOP=2
  # pushd ../sampleconfig/
  cp crypto-config.yaml.orig crypto-config.yaml 
  echo "Nothing to be done" $NOP
  # popd
fi


##########################################################
# Updating configtx.yaml File
##########################################################


cp profile_configtx.yaml configtx.yaml

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

# Profile Section Completed

# Updating Organizations Section
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

# Organization Section Completed


# Updating Orderer Section

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


# Updating Application Section

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
