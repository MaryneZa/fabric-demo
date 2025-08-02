## --------------------------------------
. utils/helper.sh

export FABRIC_CFG_PATH=${PWD}/config


infoln "Generate network artifact >> channel.tx, genesis.block"

if [ -d "./artifacts/channel/" ] ; then
    warnln "remove existing artifacts/channel/"
    rm -rf artifacts/channel/
fi

SYS_CHANNEL="sys-channel"

CHANNEL_NAME="mychannel"

## Generate the Genesis Block
infoln "----- Generate the Genesis Block -----"
configtxgen -profile OrdererGenesis -channelID $SYS_CHANNEL -outputBlock ./artifacts/channel/genesis.block

## Generate the Channel Configuration Transaction
infoln "---- Generate the Channel Configuration Transaction ----"
configtxgen -profile OrgsChannel -channelID $CHANNEL_NAME -outputCreateChannelTx ./artifacts/channel/mychannel.tx

## Generate Anchor Peer Update Transactions for Org1MSP
infoln "----- Generate Anchor Peer Update Transactions for Org1MSP -----"
configtxgen -profile OrgsChannel -channelID $CHANNEL_NAME -outputAnchorPeersUpdate ./artifacts/channel/Org1MSPanchors.tx -asOrg Org1MSP

## Generate Anchor Peer Update Transactions for Org2MSP
infoln "---- Generate Anchor Peer Update Transactions for Org2MSP ----"
configtxgen -profile OrgsChannel -channelID $CHANNEL_NAME -outputAnchorPeersUpdate ./artifacts/channel/Org2MSPanchors.tx -asOrg Org2MSP

## List final outputs for verification
infoln "Generated files in ./artifacts/channel:"
ls -l artifacts/channel