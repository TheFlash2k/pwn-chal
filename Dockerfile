FROM ubuntu:24.04@sha256:2e863c44b718727c860746568e1d54afd13b2fa71b160f5cd9058fc436217b30

RUN  mkdir -p /app/
WORKDIR /app
RUN useradd ctf-player

RUN apt update && \
    apt install -y xinetd && \
    apt clean && \
    rm -rf ~/.cache /var/lib/apt/lists/*

# Setting up challenge stuff
COPY utilities/flag.txt /app/flag.txt
COPY utilities/chal /app/chal
COPY utilities/ynetd /opt/ynetd
COPY utilities/socat /opt/socat
COPY utilities/xinetd.service /opt/xinetd.service
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
