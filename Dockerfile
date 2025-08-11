FROM ubuntu:25.04@sha256:5487c53773e2a8576213d1a2e18148fe167fabecfe7844724792f63041190d9d

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
COPY utilities/readflag /readflag
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