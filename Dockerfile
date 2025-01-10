FROM ubuntu:24.04@sha256:6e75a10070b0fcb0bead763c5118a369bc7cc30dfc1b0749c491bbb21f15c3c7

RUN  mkdir -p /app/
WORKDIR /app
RUN useradd ctf

# Downloading iptables
ENV DEBIAN_FRONTEND=noninteractive
RUN rm -rf /var/lib/apt/lists/* && \
	apt update && \
	apt install -y iptables && \
	apt clean -y && \
	apt autoclean -y && \
	rm -rf /var/lib/apt/lists/*

# Setting up challenge stuff
COPY utilities/flag.txt /app/flag.txt
COPY utilities/chal /app/chal
COPY utilities/ynetd /opt/ynetd
COPY utilities/socat /opt/socat
COPY utilities/block-outbound.sh /etc/block-outbound.sh
RUN chmod +x /opt/*

# Setting up challenge stuff
COPY utilities/flag.txt /app/flag.txt
COPY utilities/chal /app/chal
COPY utilities/ynetd /opt/ynetd
COPY utilities/socat /opt/socat
RUN chmod +x /opt/*

# Setting up log stuff
RUN touch /var/log/chal.log
RUN chown -R root:ctf /var/log/chal.log
RUN chmod 740 /var/log/chal.log

# Other measures
RUN chmod o-rwx / 2>/dev/null
RUN chmod 750 /app && chmod +x /app/chal

COPY docker-entrypoint.sh /docker-entrypoint.sh
CMD ["/docker-entrypoint.sh"]
