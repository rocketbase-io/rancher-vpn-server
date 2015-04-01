FROM ubuntu:14.04

MAINTAINER Manel Martinez <manel@nixelsolutions.com>

RUN apt-get update && \
    apt-get install -y openssh-server openvpn easy-rsa iptables rsync ipcalc sshpass

RUN mkdir -p /var/run/sshd
RUN perl -p -i -e "s/^Port .*/Port 2222/g" /etc/ssh/sshd_config
RUN perl -p -i -e "s/#?PasswordAuthentication .*/PasswordAuthentication yes/g" /etc/ssh/sshd_config
RUN perl -p -i -e "s/#?PermitRootLogin .*/PermitRootLogin yes/g" /etc/ssh/sshd_config
RUN grep ClientAliveInterval /etc/ssh/sshd_config >/dev/null 2>&1 || echo "ClientAliveInterval 60" >> /etc/ssh/sshd_config

ENV VPN_PATH /etc/openvpn
ENV VPN_PASSWORD **ChangeMe**
ENV DEBUG 0

VOLUME ["/etc/openvpn"]

EXPOSE 2222/tcp
EXPOSE 1194/udp

WORKDIR /etc/openvpn

RUN mkdir -p /usr/local/bin
ADD ./bin /usr/local/bin
RUN chmod +x /usr/local/bin/*.sh
ADD ./etc/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN run-ssh.sh
RUN run-vpn.sh
CMD ["/usr/bin/supervisord"]
