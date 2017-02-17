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
# Toon has picked the port numbers
EXPOSE 6845 60606
ENTRYPOINT ["/usr/local/sbin/geth"]
