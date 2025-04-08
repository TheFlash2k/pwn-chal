#!/bin/bash

function debug() { [ ! -z "$DEBUG" ] && echo -e "\e[32m[*]\e[0m $1"; }
function info() { echo -e "\e[36m[i]\e[0m $1"; }
function error() { echo -e "\e[31m[x]\e[0m $1"; exit 1; }
function warn() { echo -e "\e[33m[!]\e[0m $1"; }

EXTRACT_DIR="/tmp/initramfs"
EXPLOIT_PATH="/exploit"
CHAL_DIR="/chal"

# We need to reset the iptables rules
if [[ "$BLOCK_OUTBOUND" == "y" ]]; then
	iptables -F &>/dev/null
	if [[ $? != 4 ]]; then
		# We will unblock all the rules first:
		iptables -P INPUT ACCEPT
		iptables -P FORWARD ACCEPT
		iptables -P OUTPUT ACCEPT
	fi
fi

# Update: I overwrote the existing initramfs and it got corrupted.
# so, what I did is now the initramfs will be kept in /chal and the
# main one will always be inside the /app
mkdir -p "$CHAL_DIR"
[[ -f "$CHAL_DIR/$INITRAMFS" ]] && rm -f "$CHAL_DIR/$INITRAMFS"

mkdir "$EXTRACT_DIR"
cd "$EXTRACT_DIR"
cp "/app/$INITRAMFS" .
gunzip "$INITRAMFS"
# Remove the .gz extension
NO_GZINITRAMFS="${INITRAMFS%.gz}"
cpio -idm < "$NO_GZINITRAMFS"
rm -f "$NO_GZINITRAMFS" "$INITRAMFS" exploit

flag_name="`basename $FLAG_FILE`"
cp "$FLAG_FILE" "$EXTRACT_DIR/$flag_name"
chmod 400 "$EXTRACT_DIR/$flag_name"

# Get the exploit:
if [[ "$MODE" == "remote" ]]; then
	info "Please provide the exploit URL: "
	read EXPLOIT_URL
	wget "$EXPLOIT_URL" -O "$EXTRACT_DIR$EXPLOIT_PATH"
	[ $? != 0 ] && rm -f "$EXTRACT_DIR$EXPLOIT_PATH"
elif [[ "$MODE" == "stdin" ]]; then
	info "Please enter base64 encoded exploit: "
	read EXPLOIT_B64
	info "Exploit downloaded successfully. Building image."
	echo "$EXPLOIT_B64" | base64 -d > "$EXTRACT_DIR$EXPLOIT_PATH"
	[ $? != 0 ] && rm -f "$EXTRACT_DIR$EXPLOIT_PATH"
else
	error "Invalid mode: $MODE"
fi

# We check if exploit is non-empty.
if [ -f "$EXTRACT_DIR$EXPLOIT_PATH" ]; then
	# only exec perms to prevent unintended schenanigans
	chmod 111 "$EXTRACT_DIR$EXPLOIT_PATH"
	[ ! -s "$EXTRACT_DIR$EXPLOIT_PATH" ] &&  rm -f "$EXTRACT_DIR$EXPLOIT_PATH"
fi

if [[ "$BLOCK_OUTBOUND" == "y" ]]; then
	iptables -F &>/dev/null
	if [[ $? != 4 ]]; then
		/etc/block-outbound.sh &>/dev/null
		[[ $? == 0 ]] && info "Blocked all outbound connections."
	fi
fi

# Compress the initramfs
find . -print0 \
| cpio --null -ov --format=newc \
| gzip -9 > "/tmp/$INITRAMFS"
mv "/tmp/$INITRAMFS" "/chal/$INITRAMFS"
rm -rf "$EXTRACT_DIR"

info "Starting the kernel"

/usr/bin/qemu-system-x86_64 \
	-nographic \
	-cpu $CPU \
	-no-reboot \
	-monitor none,server,nowait,nodelay,reconnect=-1 \
	-initrd "/chal/$INITRAMFS" \
	-kernel "/app/$KERNEL" \
	-append "console=ttyS0 quiet $KASLR $KPTI $PANIC_ON_OOPS $SMEP $SMAP root=$ROOT rw init=$INIT" \
	-m "$MEMORY" \
	-smp "$SMP" \
	2>&1