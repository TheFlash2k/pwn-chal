#!/bin/bash
# Author: @TheFlash2k

# self-yeet
rm -- "$0"

DEFAULT_PORT=8000
DEFAULT_CHAL_NAME="chal"
DEFAULT_BASE="ynetd"
DEFAULT_LOG_FILE="/var/log/chal.log"
DEFAULT_START_DIR="/app"
DEFAULT_FLAG_FILE="/app/flag.txt"
DEFAULT_REDIRECT_STDERR="y"
DEFAULT_CONN_TIME="30"
DEFAULT_FORCE_FLAG_RO="y"
DEFAULT_BLOCK_OUTBOUND="n"

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
PORT=$(set_default "PORT")
CHAL_NAME=$(set_default "CHAL_NAME")
BASE=$(set_default "BASE")
LOG_FILE=$(set_default "LOG_FILE")
START_DIR=$(set_default "START_DIR")
FLAG_FILE=$(set_default "FLAG_FILE")
REDIRECT_STDERR=$(set_default "REDIRECT_STDERR")
CONN_TIME=$(set_default "CONN_TIME")
FORCE_FLAG_RO=$(set_default FORCE_FLAG_RO)
BLOCK_OUTBOUND=$(set_default "BLOCK_OUTBOUND")

debug "PORT=$PORT"
debug "CHAL_NAME=$CHAL_NAME"
debug "BASE=$BASE"
debug "LOG_FILE=$LOG_FILE"
debug "START_DIR=$START_DIR"
debug "FLAG_FILE=$FLAG_FILE"
debug "REDIRECT_STDERR=$REDIRECT_STDERR"
debug "CONN_TIME=$CONN_TIME"
debug "FORCE_FLAG_RO=$FORCE_FLAG_RO"
debug "BLOCK_OUTBOUND=$BLOCK_OUTBOUND"

# Check if REDIRECT_STDERR is y/n
shopt -s nocasematch
[[ "$REDIRECT_STDERR"  != "y" && "$REDIRECT_STDERR" != "n" ]] && invalid "REDIRECT_STDERR" "y/n"
shopt -u nocasematch

# Check if root:
[ "$EUID" -eq 0 ] &&  chown -R root:ctf /app/

if [ -z "$OVERRIDE_USER" ]; then
    RUN_AS="ctf"
else
    # Check if user exists:
    if id "$OVERRIDE_USER" >/dev/null 2>&1; then
        RUN_AS="$OVERRIDE_USER"
    else
        warn "User $OVERRIDE_USER user doesn't exist. Defaulting to root."
        RUN_AS="root"
    fi
fi

[[ "$BASE" != "ynetd" && "$BASE" != "socat" ]] && invalid "BASE" "ynetd/socat"
[ ! -f "/app/$CHAL_NAME" ] &&  error "No base-binary found: \e[33m/app/$CHAL_NAME\e[0m"
[ "$CHAL_NAME" != "$DEFAULT_CHAL_NAME" ] &&  rm -f "/app/$DEFAULT_CHAL_NAME"

if [ "$FLAG_FILE" != "$DEFAULT_FLAG_FILE" ]; then
    rm -f "$DEFAULT_FLAG_FILE"
    # Generate the symlink if `$FLAG_FILE_SYMLINK` is set.
    [ ! -z "$FLAG_FILE_SYMLINK" ] && (ln -s "$FLAG_FILE" "$DEFAULT_FLAG_FILE"; debug "Creating a symbolic link of $FLAG_FILE to $DEFAULT_FLAG_FILE")
fi

# Check if the running-container is a python container:
if [[ "$1" == "IS_PY" ]]; then
    debug "Checking if /app/$CHAL_NAME" contains the shebang
    # Check if the first line of `/app/$CHAL_NAME` is not a shebang; add it:
    FIRSTLINE=$(head -n 1 "/app/$CHAL_NAME")
    if [ ! "${FIRSTLINE:0:3}" == '#!/' ]; then
        (echo '#!/usr/bin/env python3' | cat - "/app/$CHAL_NAME") > tmp && mv tmp "/app/$CHAL_NAME"
    fi
    INVOKE=python3
fi

# Setting the permissions 550 on the /app/CHAL_NAME and 440 on flag
# Since we're not sure the flag is in / or /app (I sometimes add in / as well)
# So, I'm going to go for a wildcard:
chown root:$RUN_AS /app/$CHAL_NAME "$FLAG_FILE" /flag* &>/dev/null
chmod 550 "/app/$CHAL_NAME"
chmod 440 "$FLAG_FILE" /flag* &>/dev/null

if [ ! -z "$SETUID_USER" ]; then
    # default to root
    if ! id "$SETUID_USER" >/dev/null 2>&1; then
        SETUID_USER="root"
    fi
    chown "$SETUID_USER":"$SETUID_USER" "/app/$CHAL_NAME" "$FLAG_FILE" /flag* /app/flag* &>/dev/null
    chmod 4755 "/app/$CHAL_NAME"
    info "Setting the SUID bit on /app/$CHAL_NAME for user $SETUID_USER"
    [[ $FORCE_FLAG_RO == "y" ]] && chmod 400 "$FLAG_FILE" /flag* /app/flag* &>/dev/null
fi

# Making the files read-only (only works if permissions allowed to the running container)
chattr +i "$FLAG_FILE" "/app/$CHAL_NAME" &>/dev/null

###### QEMU SETUP #######
[ -z "$LIBRARY_PATH" ] && error "LIBRARY_PATH not set!"
[ -z "$EMULATOR" ] && error "EMULATOR not specified!"

ln -s "$LIBRARY_PATH/lib/ld-linux-aarch64.so.1" "/usr/lib/ld-linux-aarch64.so.1" &>/dev/null
ln -s "$LIBRARY_PATH/lib/libc.so.6" "/lib/libc.so.6" &>/dev/null
if [[ "$EMULATOR" == "qemu-arm" ]]; then
    ln -s "$LIBRARY_PATH/lib/ld-linux-armhf.so.3" "/lib/ld-linux-armhf.so.3" &>/dev/null
else
    ln -s "$LIBRARY_PATH/lib/ld-linux.so.3" "/lib/ld-linux.so.3" &>/dev/null
    ln -s /usr/lib/ld-linux-aarch64.so.1 "/lib/ld-linux-aarch64.so.1" &>/dev/null
fi

export LD_LIBRARY_PATH="$LIBRARY_PATH"
info "[\e[33mQEMU\e[0m] using \e[32m$EMULATOR\e[0m and libaries @ \e[36m$LIBRARY_PATH\e[0m"

cd "$START_DIR";

env > /etc/environment
# Run the gdb server, host the binary.
## NOTE: The binary will be hosted, but the stdin/out/err won't be redirected, so you'll have to communicate using docker :(
# if someone can help me with this, that'll be helpful, ty.
if [ ! -z "$QEMU_GDB_PORT" ]; then
    info "[\e[33mGDB\e[0m] Enabling QEMU's GDB remote debugging on \e[36m$QEMU_GDB_PORT\e[0m"
    while [[ 1 ]]; do
        LD_LIBRARY_PATH="$LD_LIBRARY_PATH" $EMULATOR -g $QEMU_GDB_PORT -L "$LIBRARY_PATH" "/app/$CHAL_NAME"
    done
    exit 0
fi

# Added this specifically for Showdown (No flag, only submitter binary)
[ ! -z "$NO_FLAG" ] && rm -f "$FLAG_FILE"

# Could be cleaned up but im lazy asf
if [[ "$BLOCK_OUTBOUND" == "y" ]]; then
    iptables 2>&1 >/dev/null
    if [[ $? == 4 ]]; then
        warn "CAP_NET_ADMIN is not set. Please set that to block outbound connections"
    else
        info "Blocking all outbound connections"
        /etc/block-outbound.sh
        [[ $? != 0 ]] && \
            warn "Failed to block outbound connections!" || \
            info "Blocked all outbound connections."
        fi
    fi
fi

info "Running \e[33m$CHAL_NAME\e[0m in \e[32m$(pwd)\e[0m as \e[36m$RUN_AS\e[0m using \e[35m$BASE\e[0m and listening locally on \e[34m$PORT\e[0m using \e[33m$EMULATOR\e[0m"
if [ "$BASE" == "socat" ]; then
    rm -f /opt/ynetd
    [ "$REDIRECT_STDERR" == "y" ] && REDIRECT_STDERR=",stderr" || REDIRECT_STDERR=
    LD_LIBRARY_PATH="$LD_LIBRARY_PATH" "$EMULATOR" -L "$LIBRARY_PATH" /bin/su $RUN_AS -c "/opt/socat tcp-l:$PORT,reuseaddr,fork, EXEC:\"/app/$CHAL_NAME\"$REDIRECT_STDERR | tee -a $LOG_FILE"
elif [ "$BASE" == "ynetd" ]; then
    rm -f /opt/socat
    # -lt => cpu time in seconds. Keeps connection opened for max 10 seconds.
    # -se => stderr to redirect to socket
    LD_LIBRARY_PATH="$LD_LIBRARY_PATH" $EMULATOR -L "$LIBRARY_PATH" /opt/ynetd -lt 1 -p $PORT -u $RUN_AS -se y -d $START_DIR "/app/$CHAL_NAME" | tee -a $LOG_FILE
else
    error "Invalid base: $BASE"
fi