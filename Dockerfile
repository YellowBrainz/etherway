FROM centos:latest
MAINTAINER Maxim B. Belooussov <belooussov@gmail.com>
ENV DATADIR=/datadir
RUN mkdir -p $DATADIR
#RUN yum -y update
RUN yum -y groupinstall "Development Tools"
RUN yum -y install golang
RUN git clone https://github.com/ethereum/go-ethereum
# Davy Jones' Locker
ARG ETHVERSION=v1.5.9
RUN cd /go-ethereum && git checkout $ETHVERSION && make geth && cp /go-ethereum/build/bin/* /usr/local/sbin/
#RUN yum -y remove golang
RUN rm -rf /go-ethereum

RUN yum -y install epel-release
RUN yum -y update
RUN yum -y install nodejs npm
RUN git clone https://github.com/ing-bank/eth-net-intelligence-api.git /eth-net-intelligence-api
RUN cd /eth-net-intelligence-api && npm install -d && npm install pm2 -g
COPY artifacts/app.json /eth-net-intelligence-api/app.json
ENV WS_SECRET g3heim
#WORKDIR /eth-net-intelligence-api
#ENTRYPOINT ["pm2","start","--no-daemon","app.json"]
# Toon has picked the port numbers
EXPOSE 6845 60606
ENTRYPOINT ["/usr/local/sbin/geth"]
