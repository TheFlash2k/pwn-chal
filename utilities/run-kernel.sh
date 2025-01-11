#!/bin/bash

function debug() { [ ! -z "$DEBUG" ] && echo -e "\e[32m[*]\e[0m $1"; }
function info() { echo -e "\e[36m[i]\e[0m $1"; }
function error() { echo -e "\e[31m[x]\e[0m $1"; exit 1; }
function warn() { echo -e "\e[33m[!]\e[0m $1"; }

# Here we will decompress the initramfs
EXTRACT_DIR="/tmp/initramfs"
mkdir "$EXTRACT_DIR"
cd "$EXTRACT_DIR"
cp "/app/$INITRAMFS" .
gunzip "$INITRAMFS"
# Remove the .gz extension
NO_GZINITRAMFS="${INITRAMFS%.gz}"
cpio -idm < "$NO_GZINITRAMFS"
rm -f "$NO_GZINITRAMFS"  "$INITRAMFS" exploit

flag_name="`basename $FLAG_FILE`"
cp "$FLAG_FILE" "$EXTRACT_DIR/$flag_name"
chmod 400 "$EXTRACT_DIR/$flag_name"

# Get the exploit:
if [[ "$MODE" == "remote" ]]; then
    info "Please provide the exploit URL"
    read EXPLOIT_URL
    wget "$EXPLOIT_URL" -O "$EXTRACT_DIR/exploit"
elif [[ "$MODE" == "stdin" ]]; then
    info "Enter base64 encoded exploit"
    read EXPLOIT_B64
    echo "$EXPLOIT_B64" | base64 -d > "$EXTRACT_DIR/exploit"
else
    error "Invalid mode: $MODE"
fi
chmod +x "$EXTRACT_DIR/exploit"

# Now run iptables and block outbound:
if [[ "$BLOCK_OUTBOUND" == "y" ]]; then
    iptables -F &>/dev/null
    if [[ $? == 4 ]]; then
        warn "CAP_NET_ADMIN is not set. Please set that to block outbound connections"
    else
        /etc/block-outbound.sh &>/dev/null
        [[ $? != 0 ]] && \
            warn "Failed to block outbound connections!" || \
            info "Blocked all outbound connections."
    fi
fi
rm -f /etc/block-outbound.sh

# Compress the initramfs
find . -print0 \
| cpio --null -ov --format=newc \
| gzip -9 > "/tmp/$INITRAMFS"
mv "/tmp/$INITRAMFS" "/app/$INITRAMFS"
rm -rf "$EXTRACT_DIR"

info "Starting the kernel"
/usr/bin/qemu-system-x86_64 \
	-nographic \
	-cpu $CPU \
	-no-reboot \
	-monitor none,server,nowait,nodelay,reconnect=-1 \
	-initrd "/app/$INITRAMFS" \
	-kernel "/app/$KERNEL" \
	-append "console=ttyS0 quiet $KASLR $KPTI $PANIC_ON_OOPS" \
	-m "$MEMORY" \
	-smp "$SMP" \
    2>&1