FROM theflash2k/pwn-chal:latest

RUN  apt update && \
    DEBIAN_FRONTEND=noninteractive apt install -y libstdc++-11-dev && \
    apt-get clean

# Removing unnecessary packages
RUN rm -rf /var/cache/apt/archives \
    /var/lib/apt/lists \
    /usr/lib/gcc/x86_64-linux-gnu/11/{cc1plus,cc1,lto1,libstdc++.a,libgcc.a}
