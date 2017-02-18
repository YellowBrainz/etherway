FROM centos:latest
MAINTAINER Maxim B. Belooussov <belooussov@gmail.com> Toon Leijtens <toon.leijtens@gmail.com>
RUN yum -y groupinstall "Development Tools"
RUN yum -y install golang
RUN git clone https://github.com/ethereum/go-ethereum

# Davy Jones' Locker
ARG ETHVERSION=v1.5.7
RUN cd /go-ethereum && git checkout $ETHVERSION && make geth && cp /go-ethereum/build/bin/* /usr/local/sbin/
RUN yum -y remove golang
RUN rm -rf /go-ethereum

RUN yum -y install epel-release
RUN yum -y update
RUN yum -y install libusb
RUN yum -y install nodejs npm
RUN git clone https://github.com/cubedro/eth-net-intelligence-api /eth-net-intelligence-api
RUN cd /eth-net-intelligence-api && npm install -d && npm install pm2 -g
COPY artifacts/app.json /eth-net-intelligence-api/app.json
ENV WS_SECRET g3heim
#WORKDIR /eth-net-intelligence-api
#ENTRYPOINT ["pm2","start","--no-daemon","app.json"]

# eth-netstats
RUN git clone https://github.com/cubedro/eth-netstats
RUN cd /eth-netstats && npm install
RUN cd /eth-netstats && npm install -g grunt-cli
RUN cd /eth-netstats && grunt

RUN mkdir /root/.ethereum
ENV DATADIR=/root/.ethereum
WORKDIR $DATADIR
COPY artifacts/genesis.json /root/.ethereum/
COPY artifacts/credentials.* /root/.ethereum/
COPY artifacts/key.* /root/.ethereum/
COPY artifacts/static-nodes.json /root/.ethereum/

ARG NETWORKID=66
ENV NETWORKID $NETWORKID

RUN for i in admin user1 user2 user3 user4 user5 user6; do \
    /usr/local/sbin/geth --datadir /root/.ethereum --password /root/.ethereum/credentials.$i account new > /root/.ethereum/$i.id; \
    sed -i "s/Address: {//g" /root/.ethereum/$i.id; \
    sed -i "s/}//g" /root/.ethereum/$i.id; \
    sed -i "s/$i/0x$(cat /root/.ethereum/$i.id)/" /root/.ethereum/genesis.json; \
    done

COPY artifacts/entrypoint.sh /entrypoint.sh
RUN sed -i "s/adminetherbase/0x$(cat /root/.ethereum/admin.id)/" /entrypoint.sh

RUN /usr/local/sbin/geth --networkid $NETWORKID init /root/.ethereum/genesis.json

ARG NETWORKPORT=30303
ENV NETWORKPORT $NETWORKPORT

ARG RPCPORT=8545
ENV RPCPORT $RPCPORT

ARG MONITORPORT=3000
ENV MONITORPORT $MONITORPORT

# Toon has picked the port numbers
EXPOSE $RPCPORT $NETWORKPORT $MONITORPORT
ENTRYPOINT ["/entrypoint.sh"]
