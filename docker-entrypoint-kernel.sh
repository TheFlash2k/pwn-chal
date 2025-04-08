#!/bin/bash
# Author: @TheFlash2k

# self-yeet
rm -f -- "$0"

DEFAULT_PORT=8000
DEFAULT_LOG_FILE="/var/log/chal.log"
DEFAULT_FLAG_FILE="/app/flag.txt"
DEFAULT_CONN_TIME="30"
DEFAULT_BLOCK_OUTBOUND="y"
DEFAULT_POW="0"

# Kernel based variables
DEFAULT_KASLR=1
DEFAULT_KPTI=1
DEFAULT_SMEP=1
DEFAULT_SMAP=1
DEFAULT_PANIC_ON_OOPS=1
DEFAULT_MODE="remote"
DEFAULT_VM_MEMORY="128M"
DEFAULT_INITRAMFS="initramfs.cpio.gz"
DEFAULT_KERNEL="vmlinuz"
DEFAULT_CPU="qemu64"
DEFAULT_SMP="1"
DEFAULT_INIT="/init"
DEFAULT_ROOT="/dev/ram"

function debug() { [ ! -z "$DEBUG" ] && echo -e "\e[32m[*]\e[0m $1"; }
function info() { echo -e "\e[36m[i]\e[0m $1"; }
function error() { echo -e "\e[31m[x]\e[0m $1"; exit 1; }
function warn() { echo -e "\e[33m[!]\e[0m $1"; }
function set_default() {
    # Takes a variable name as a parameter
    # Returns the already set value if value exists otherwise sets to DEFAULT_variableName
    local var="$1"
    local __="DEFAULT_$var"
    local default="${!__}"

    if [ -z "${!var}" ]; then
        eval "$var=\$default"
    else
        eval "$var=\${!var}"
    fi
    echo -n "${!var}"
}

function invalid() {
    local opt="$1"
    error "$opt is set to ${!opt}. Can only be ($2)";
}

[ ! -z "$DEBUG" ] && debug "Debugging is enabled!"

# Check the variables, if not exists, set to default
export PORT=$(set_default "PORT")
export LOG_FILE=$(set_default "LOG_FILE")
export FLAG_FILE=$(set_default "FLAG_FILE")
export CONN_TIME=$(set_default "CONN_TIME")
export BLOCK_OUTBOUND=$(set_default "BLOCK_OUTBOUND")
export POW=$(set_default "POW")

# Kernel Defaults
export KASLR=$(set_default "KASLR")
export KPTI=$(set_default "KPTI")
export SMEP=$(set_default "SMEP")
export SMAP=$(set_default "SMAP")
export PANIC_ON_OOPS=$(set_default "PANIC_ON_OOPS")
export MODE=$(set_default "MODE")
export CPU=$(set_default "CPU")
export VM_MEMORY=$(set_default "VM_MEMORY")
export INITRAMFS=$(set_default "INITRAMFS")
export KERNEL=$(set_default "KERNEL")
export APPEND=$(set_default "APPEND")
export SMP=$(set_default "SMP")
export INIT=$(set_default "INIT")
export ROOT=$(set_default "ROOT")

[[ $SMAP == 1 ]] && SMAP="+smap" || SMAP="nosmap"
[[ $SMEP == 1 ]] && SMEP="+smep" || SMEP="nosmep"
[[ $KASLR == 0 ]] && KASLR="nokaslr" || KASLR="kaslr"
[[ $KPTI == 0 ]] && KPTI="nokpti" || KPTI="kpti=1"
[[ $PANIC_ON_OOPS == 1 ]] && PANIC_ON_OOPS=" oops=panic panic=-1"

debug "PORT=$PORT"
debug "LOG_FILE=$LOG_FILE"
debug "FLAG_FILE=$FLAG_FILE"
debug "CONN_TIME=$CONN_TIME"
debug "BLOCK_OUTBOUND=$BLOCK_OUTBOUND"
debug "POW=$POW"
debug "KASLR=$KASLR"
debug "CPU=$CPU"
debug "KPTI=$KPTI"
debug "SMEP=$SMEP"
debug "SMAP=$SMAP"
debug "PANIC_ON_OOPS=$PANIC_ON_OOPS"
debug "MODE=$MODE"
debug "MEMORY=$VM_MEMORY"
debug "INITRAMFS=$INITRAMFS"
debug "KERNEL=$KERNEL"
debug "SMP=$SMP"
debug "ROOT=$ROOT"
debug "INIT=$INIT"

shopt -s nocasematch
[[ "$MODE" != "remote" && "$MODE" != "stdin" ]] && invalid "MODE" "remote/stdin"
[[ "$CPU" != "qemu64" && "$CPU" != "kvm64" ]] && invalid "CPU" "qemu64/kvm64"
shopt -u nocasematch

# Check if INITRAMFS, KERNEL and FLAG_FILE exists
[ ! -f "$INITRAMFS" ] && error "INITRAMFS file not found!"
[ ! -f "$KERNEL" ] && error "KERNEL file not found!"
[ ! -f "$FLAG_FILE" ] && error "FLAG_FILE file not found!"

# Dump it.
env > /etc/environment

# POW range is 0-256
if [[ "$POW" -lt 0 ]] || [[ "$POW" -gt 256 ]]; then
    warn "POW is set to $POW. It should be between 0-256. Defaulting to 0."
    POW=0
fi

if [ "$POW" -gt 0 ]; then
    info "Using Proof-of-Work difficulty: $POW"
fi

info "Running a \e[33m/app/run-kernel.sh\e[0m and listening locally on \e[34m$PORT\e[0m"
/opt/ynetd -lt "$CONN_TIME" -pow "$POW" -se y -p $PORT -d "/app" "/app/run-kernel.sh"
