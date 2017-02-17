AUTHOR=banking
NAME=etherway
NETWORKID=66
NETWORKPORT=60606
SUBNET=10.0.66
VERSION=latest
PWD=/dockerbackup
NETWORKNAME=etherway
MINERPORT=6845
ETHSTATSPORT=6000
FULLDOCKERNAME=$(AUTHOR)/$(NAME):$(VERSION)

build:
	docker build -t $(FULLDOCKERNAME) .

start: network cashcow ethbox dashboard dashboardclient

stop:
	docker stop -t 0 cashcow
	docker stop -t 0 ethbox
	docker stop -t 0 dashboard
	docker stop -t 0 dashboardclient

clean:
	docker rm -f cashcow
	docker rm -f ethbox
	docker rm -f dashboard
	docker rm -f dashboardclient
	docker network rm $(NETWORKNAME)

cleanrestart: clean start

network:
	docker network create --subnet $(SUBNET).0/16 --gateway $(SUBNET).254 $(NETWORKNAME)

datavolumes:
	docker run -d -v ethereumcashcow:/root --name data-eth_cashcow --entrypoint /bin/echo $(AUTHOR)/$(NAME):$(VERSION)
	docker run -d -v ethereumethbox:/root --name data-eth_ethbox --entrypoint /bin/echo $(AUTHOR)/$(NAME):$(VERSION)
	docker run -d -v ethereumbox2:/root --name data-eth_box2 --entrypoint /bin/echo $(AUTHOR)/$(NAME):$(VERSION)

rmnetwork:
	docker network rm $(NETWORKNAME)

help:
	docker run -i $(AUTHOR)/$(NAME):$(VERSION) help

cashcow:
	docker run -d --name=cashcow -h cashcow --net $(NETWORKNAME) --ip $(SUBNET).1 -e SUBNET=$(SUBNET) --volumes-from data-eth_cashcow -p $(MINERPORT):$(MINERPORT) $(AUTHOR)/$(NAME):$(VERSION) cashcow

ethbox:
	docker run -d --name=ethbox -h ethbox --net $(NETWORKNAME) --ip $(SUBNET).2 -e SUBNET=$(SUBNET) --volumes-from data-eth_ethbox $(AUTHOR)/$(NAME):$(VERSION) ethbox

dashboardclient:
	docker run -d --name=dashboardclient -h dashboardclient --net $(NETWORKNAME) --ip $(SUBNET).3 -e SUBNET=$(SUBNET) $(AUTHOR)/$(NAME):$(VERSION) dashboardclient

dashboard:
	docker run -d --name=dashboard -h dashboard --net $(NETWORKNAME) --ip $(SUBNET).4 -e SUBNET=$(SUBNET) -p $(ETHSTATSPORT):$(ETHSTATSPORT) $(AUTHOR)/$(NAME):$(VERSION) dashboard

console:
	docker exec -ti cashcow /usr/local/sbin/geth attach ipc:/root/.ethereum/geth.ipc

