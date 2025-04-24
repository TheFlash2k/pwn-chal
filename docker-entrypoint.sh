#!/bin/bash
# Author: @TheFlash2k

# self-yeet
rm -f -- "$0"

DEFAULT_PORT=8000
DEFAULT_CHAL_NAME="chal"
DEFAULT_CHAL_NAME_WINDOWS="chal.exe"
DEFAULT_BASE="ynetd"
DEFAULT_START_DIR="/app"
DEFAULT_FLAG_FILE="/app/flag.txt"
DEFAULT_REDIRECT_STDERR="y"
DEFAULT_CONN_TIME="30"
DEFAULT_FORCE_FLAG_RO="y"
DEFAULT_BLOCK_OUTBOUND="y"
DEFAULT_POW="0"
DEFAULT_ROOT_ONLY_FLAG="n"
DEFAULT_ADD_READFLAG="n"

# These 2 are used when ADD_READFLAG is set.
DEFAULT_UID_READFLAG="0"
DEFAULT_GID_READFLAG="0"

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
START_DIR=$(set_default "START_DIR")
FLAG_FILE=$(set_default "FLAG_FILE")
REDIRECT_STDERR=$(set_default "REDIRECT_STDERR")
CONN_TIME=$(set_default "CONN_TIME")
FORCE_FLAG_RO=$(set_default "FORCE_FLAG_RO")
BLOCK_OUTBOUND=$(set_default "BLOCK_OUTBOUND")
POW=$(set_default "POW")
ROOT_ONLY_FLAG=$(set_default "ROOT_ONLY_FLAG")
ADD_READFLAG=$(set_default "ADD_READFLAG")
UID_READFLAG=$(set_default "UID_READFLAG")
GID_READFLAG=$(set_default "GID_READFLAG")

debug "PORT=$PORT"
debug "CHAL_NAME=$CHAL_NAME"
debug "BASE=$BASE"
debug "START_DIR=$START_DIR"
debug "FLAG_FILE=$FLAG_FILE"
debug "REDIRECT_STDERR=$REDIRECT_STDERR"
debug "CONN_TIME=$CONN_TIME"
debug "FORCE_FLAG_RO=$FORCE_FLAG_RO"
debug "BLOCK_OUTBOUND=$BLOCK_OUTBOUND"
debug "POW=$POW"
debug "ROOT_ONLY_FLAG=$ROOT_ONLY_FLAG"
debug "ADD_READFLAG=$ADD_READFLAG"
debug "UID_READFLAG=$UID_READFLAG"
debug "GID_READFLAG=$GID_READFLAG"

# Check if REDIRECT_STDERR is y/n
shopt -s nocasematch
[[ "$REDIRECT_STDERR" != "y" && "$REDIRECT_STDERR" != "n" ]] && invalid "REDIRECT_STDERR" "y/n"
shopt -u nocasematch

# Check if root:
[ "$EUID" -eq 0 ] &&  chown -R root:ctf /app/

if [ -z "$OVERRIDE_USER" ]; then
    RUN_AS="ctf"
else
    # Check if user exists:
    if id "$OVERRIDE_USER" 2>&1 >/dev/null; then
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
if [[ "$1" == "IS_PY" || "$IS_PY" ]]; then
    debug "Checking if /app/$CHAL_NAME" contains the shebang
    # Check if the first line of `/app/$CHAL_NAME` is not a shebang; add it:
    FIRSTLINE=$(head -n 1 "/app/$CHAL_NAME")
    if [ ! "${FIRSTLINE:0:17}" == '#!/usr/local/bin/' ]; then
        (echo '#!/usr/local/bin/python' | cat - "/app/$CHAL_NAME") > tmp && mv tmp "/app/$CHAL_NAME"
    fi
    INVOKE="/usr/local/bin/python "
elif [[ "$1" == "IS_SAGE" || "$IS_SAGE" ]]; then
    INVOKE="/usr/bin/sage -python "
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

cd "$START_DIR";

if [[ "$1" == "IS_WINDOWS" ]]; then

    [ "$CHAL_NAME.exe" != "$DEFAULT_CHAL_NAME_WINDOWS" ] &&  rm -f "/app/$DEFAULT_CHAL_NAME_WINDOWS"

    [[ -z "$WINEARCH" ]] && export WINEARCH=win64
    [[ -z "$WINPREFIX" ]] && export WINEPREFIX="$HOMEDIR/.wine"
    [[ "$RUN_AS" != "root" ]] && HOMEDIR="/home/$RUN_AS" || HOMEDIR="/root"

    mkdir -p "$WINEPREFIX"
    chown -R "$RUN_AS":"$RUN_AS" "$WINEPREFIX"
    info "[\e[34mWINDOWS\e[0m] Setting up wine prefixes and registries..."
    su $RUN_AS -c "wine regedit.exe /opt/wine.req" &>/dev/null
    info "[\e[34mWINDOWS\e[0m] Setting WINEPREFIX=$WINEPREFIX"

    mv "$FLAG_FILE" "$WINEPREFIX/drive_c"
    chown "$RUN_AS:root" "$WINEPREFIX/drive_c/`basename $FLAG_FILE`"
    chmod 444 "$WINEPREFIX/drive_c/`basename $FLAG_FILE`"

    if [[ -z $WIN_DEBUG ]]; then
        info "[\e[34mWINDOWS\e[0m] Output debugging is \e[31mdisabled\e[0m"
        BASE="socat"
    else
        info "[\e[34mWINDOWS\e[0m] Output debugging is \e[32menabled\e[0m"
    fi

    info "[\e[34mWINDOWS\e[0m] Running \e[33m$CHAL_NAME\e[0m as \e[36m$RUN_AS\e[0m using \e[35m$BASE\e[0m and listening locally on \e[34m$PORT\e[0m"
    if [[ "$WIN_DEBUG" == "y" ]]; then
        rm -f /opt/socat
        xvfb-run -a /opt/ynetd -p $PORT -u "$RUN_AS" -sh n -se "$REDIRECT_STDERR" "WINEDEBUG=-all wine /app/$CHAL_NAME"
    else
        [ "$REDIRECT_STDERR" == "y" ] && REDIRECT_STDERR=",stderr" || REDIRECT_STDERR=
        (su $RUN_AS -c "xvfb-run -a /opt/socat tcp-l:$PORT,reuseaddr,fork, EXEC:\"wine /app/$CHAL_NAME\"$REDIRECT_STDERR")
    fi

    exit 0 # idk
fi

# Could be cleaned up but im lazy asf
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
# still remove if it's there
rm -f /etc/block-outbound.sh

# POW range is 0-256
if [[ "$POW" -lt 0 ]] || [[ "$POW" -gt 256 ]]; then
    warn "POW is set to $POW. It should be between 0-256. Defaulting to 0."
    POW=0
fi

# Just take write permission for everyone on libc*, ld* and $CHAL_NAME
chmod ugo-w /app/{libc*,ld*,flag.txt,$CHAL_NAME} /flag* /app/flag* &>/dev/null

# Added this specifically for Showdown (No flag, only submitter binary)
[ ! -z "$NO_FLAG" ] && rm -f "$FLAG_FILE"

if [[ "$ROOT_ONLY_FLAG" == "y" ]]; then
    info "Setting the flag to be read-only for root only."
    chown root:root $FLAG_FILE
    chmod 400 $FLAG_FILE
fi

export FLAG_FILE="$FLAG_FILE"

# For ADD_READFLAG
if [[ "$ADD_READFLAG" == "y" ]]; then
    info "Setting the flag fetch method to be /readflag"
    export UID_READFLAG="$UID_READFLAG"
    export GID_READFLAG="$GID_READFLAG"
    chown $UID_READFLAG:$GID_READFLAG $FLAG_FILE
    chmod 400 $FLAG_FILE
    chmod 4111 /readflag # only suid exec perms
else
    rm -f /readflag
fi

if [ "$POW" -gt 0 ]; then
    if [ "$BASE" == "ynetd" ]; then
        info "Using Proof-of-Work difficulty: $POW"
    else
        warn "Proof-of-Work is only supported with ynetd. Ignoring POW."
    fi
    LOCAL_POW="$POW"
fi

env > /etc/environment

info "Running \e[33m$CHAL_NAME\e[0m in \e[32m$(pwd)\e[0m as \e[36m$RUN_AS\e[0m using \e[35m$BASE\e[0m and listening locally on \e[34m$PORT\e[0m"
if [ "$BASE" == "socat" ]; then
    rm -f /opt/ynetd
    shopt -s nocasematch
    [ "$REDIRECT_STDERR" == "y" ] && REDIRECT_STDERR=",stderr" || REDIRECT_STDERR=
    su $RUN_AS -p -c "/opt/socat tcp-l:$PORT,reuseaddr,fork, EXEC:\"$INVOKE/app/$CHAL_NAME\"$REDIRECT_STDERR"
elif [ "$BASE" == "ynetd" ]; then
    rm -f /opt/socat
    /opt/ynetd -lt "$CONN_TIME" -u "$RUN_AS" -pow "$POW" -se "$REDIRECT_STDERR" -p $PORT -d $START_DIR "$INVOKE/app/$CHAL_NAME"
else
    error "Invalid base: $BASE"
fi