FROM centos:latest
MAINTAINER Maxim B. Belooussov <belooussov@gmail.com> Toon Leijtens <toon.leijtens@gmail.com>
ENV DATADIR=/root
RUN yum -y groupinstall "Development Tools"
RUN yum -y install golang
RUN yum -y install libusb
RUN git clone https://github.com/ethereum/go-ethereum

# Davy Jones' Locker
ARG ETHVERSION=v1.5.9
RUN cd /go-ethereum && git checkout $ETHVERSION && make geth && cp /go-ethereum/build/bin/* /usr/local/sbin/
RUN yum -y remove golang
RUN rm -rf /go-ethereum

RUN yum -y install epel-release
RUN yum -y update
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

WORKDIR $DATADIR
RUN cd $DATADIR
COPY artifacts/genesis.json $DATA_DIR/
COPY artifacts/credentials.* $DATA_DIR/
COPY artifacts/key.* $DATA_DIR/
COPY artifacts/static-nodes.json $DATADIR/.ethereum/

ARG NETWORKID=66
ENV NETWORKID $NETWORKID

RUN for i in admin user1 user2 user3 user4 user5 user6; do \
    /usr/local/sbin/geth --password $DATA_DIR/credentials.$i --datadir=$DATA_DIR account new > $DATA_DIR/$i.id; \
    sed -i "s/Address: {//g" $DATA_DIR/$i.id; \
    sed -i "s/}//g" $DATA_DIR/$i.id; \
    sed -i "s/$i/0x$(cat $DATA_DIR/$i.id)/" $DATA_DIR/genesis.json; \
    done

RUN /usr/local/sbin/geth --networkid $NETWORKID init $DATA_DIR/genesis.json
ARG NETWORKPORT=60606
ENV NETWORKPORT $NETWORKPORT

ARG ETHBOXPORT=6844
ENV ETHBOXPORT $ETHBOXPORT

ARG MINERPORT=6845
ENV MINERPORT $MINERPORT

ARG MONITORPORT=3000
ENV MONITORPORT $MONITORPORT

# Toon has picked the port numbers
EXPOSE $ETHBOXPORT $MINERPORT $NETWORKPORT $MONITORPORT
COPY artifacts/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
