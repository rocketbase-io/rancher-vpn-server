FROM ubuntu:latest

MAINTAINER Manel Martinez <manel@nixelsolutions.com>
MAINTAINER Niels Schelbach <niels.schelbach@rocketbase.io>

RUN apt-get update && \
    apt-get install -y openvpn iptables dnsmasq supervisor iputils-ping && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/log/supervisor

ENV VPN_PATH /etc/openvpn
ENV ROUTED_NETWORK_CIDR 10.42.0.0
ENV ROUTED_NETWORK_MASK 255.255.0.0
ENV DEBUG 0

VOLUME ["/etc/openvpn"]

EXPOSE 1194/tcp

WORKDIR /etc/openvpn

ADD etc/dnsmasq.conf /etc/dnsmasq.conf

RUN mkdir -p /usr/local/bin
ADD ./bin /usr/local/bin
RUN chmod +x /usr/local/bin/*.sh
ADD ./etc/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD ["/usr/local/bin/run.sh"]
