#!/bin/sh

OPTIONS="--nodiscover --networkid $NETWORKID --port $NETWORKPORT --rpc --rpcport $MINERPORT --etherbase 0x57e25703aba36bd2575e9027de2cb9ac187dc6da --verbosity 6"
HELP="This is a help page. \
Available modes are: miner node1 node2 ethstats ethstatsclient help."
case $1 in
	cashcow)
	cp /root/key.cashcow /root/.ethereum/nodekey
	sed -i "s/__subnet__/$SUBNET/g" /root/.ethereum/static-nodes.json
	./geth --rpccorsdomain "*" --rpcapi admin,debug,shh,txpool,miner,personal,db,eth,net,web3 --verbosity "6" --identity $1 --rpcaddr $SUBNET.1 --mine --autodag --minerthreads "1" $OPTIONS
	;;
        ethbox)
	cp /root/key.ethbox /root/.ethereum/nodekey
	sed -i "s/__subnet__/$SUBNET/g" /root/.ethereum/static-nodes.json
	./geth --rpccorsdomain "*" --rpcapi eth,net,web3,debug --verbosity "6" --identity $1 --rpcaddr $SUBNET.2 $OPTIONS
	;;
        dashboard)
	cd /eth-netstats ; npm start
	;;
        dashboardclient)
	sed -i "s/__subnet__/$SUBNET/g" /eth-net-intelligence-api/app.json
	cd /eth-net-intelligence-api ; pm2 start --no-daemon app.json
	;;
	help)
	echo $HELP
	;;
	"")
	echo $HELP
esac
