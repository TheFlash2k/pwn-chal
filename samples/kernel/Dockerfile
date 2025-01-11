FROM theflash2k/pwn-chal:kernel

ENV INITRAMFS=initramfs.cpio.gz
ENV KERNEL=bzImage

# Disable mitigations
ENV KPTI=0
ENV KASLR=0
ENV SMAP=0
ENV SMEP=0

# Set the memory limit
ENV VM_MEMORY=128M

# Setup PoW to prevent DoS
ENV POW=20

# Since pwd is /app, we can use .
COPY $INITRAMFS .
COPY $KERNEL .
