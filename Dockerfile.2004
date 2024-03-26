FROM ubuntu:20.04@sha256:80ef4a44043dec4490506e6cc4289eeda2d106a70148b74b5ae91ee670e9c35d

RUN  mkdir -p /app/
WORKDIR /app
RUN adduser --disabled-password ctf-player

# Setting up challenge stuff
COPY utilities/flag.txt /app/flag.txt
COPY utilities/chal /app/chal
COPY utilities/ynetd /opt/ynetd
COPY utilities/socat /opt/socat
RUN chmod +x /opt/*

# Setting up log stuff
RUN touch /var/log/chal.log
RUN chown -R root:ctf-player /var/log/chal.log
RUN chmod 740 /var/log/chal.log

# Other measures
RUN chmod o-rwx / 2>/dev/null
RUN chmod 750 /app && chmod +x /app/chal

COPY docker-entrypoint.sh /docker-entrypoint.sh
CMD ["/docker-entrypoint.sh"]
