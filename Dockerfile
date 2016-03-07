FROM ubuntu:14.04
MAINTAINER ARM <doug.anson@arm.com>
RUN apt-get -y install software-properties-common
RUN apt-get -y install openssh-server supervisor dnsutils
RUN apt-get -y install openjdk-7-jre
RUN apt-get -y install unzip zip
EXPOSE 22/tcp
EXPOSE 8234/tcp
EXPOSE 28519/tcp
EXPOSE 28520/tcp
RUN useradd arm -m -s /bin/bash 
RUN mkdir -p /home/arm
RUN chown arm.arm /home/arm
COPY connector-bridge.zip /home/arm/
COPY configurator-1.0.zip /home/arm/
RUN chmod 755 /home/arm/connector-bridge.zip
RUN chmod 755 /home/arm/configurator-1.0.zip
COPY ssh-keys.tar /home/arm/
RUN chmod 755 /home/arm/ssh-keys.tar
COPY configure_instance.sh /home/arm/
COPY start_instance.sh /home/arm/
COPY update_hosts.sh /home/arm/
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN chmod 700 /home/arm/configure_instance.sh
RUN chmod 700 /home/arm/start_instance.sh
RUN chmod 700 /home/arm/update_hosts.sh
RUN /home/arm/configure_instance.sh

ENTRYPOINT [ "/home/arm/start_instance.sh" ]
