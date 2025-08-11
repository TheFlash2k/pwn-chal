## PWN-CHAL - Easy remote PWN challenges deployment

[Dockerhub](https://hub.docker.com/repository/docker/theflash2k/pwn-chal/)

[Github](https://github.com/TheFlash2k/pwn-chal)

You can use this image to easily deploy your challenges without having to setup anything.

Under the hood, pwn-chal utilizes [`ynetd`](https://github.com/johnsonjh/ynetd) to serve the challenge to host. `socat` can be utilized as well by setting `BASE` environment variable.

A sample Dockerfile is as follows:

```dockerfile
FROM theflash2k/pwn-chal:latest

ENV CHAL_NAME=baby-pwn
COPY ${CHAL_NAME} ${CHAL_NAME}
COPY flag.txt flag.txt
```

| **NOTE**: Challenge binary **MUST** be placed inside the `/app` directory. Default WORKDIR is set to `/app`

The binaries will run in the context of user `ctf-player` rather than root.

| This CAN be overriden with the use of **OVERRIDE_USER** environment variable

Following environment variables can be changed to your own likings:
```bash
CHAL_NAME
PORT
BASE
START_DIR
FLAG_FILE
OVERRIDE_USER
SETUID_USER
REDIRECT_STDERR
NO_FLAG
ADD_READFLAG
ROOT_ONLY_FLAG
OUTBOUND_BLOCK
POW
```

There are other image-specific environment variables as well:

- [Kernel](#kernel)
- [Windows](#windows)
- [ARM/ARM64](#arm--arm64)


### CHAL_NAME
This is the name of the challenge binary. (I know, should've been `CHAL_BIN` or something, but ;-;).

### PORT
The port that the challenge will listen on internally. The default port is `8000`

### BASE
The BASE binary to use for listening. Can be one of the following:
1. ynetd [Default]
2. socat

### START_DIR
In case the challenge gives a shell, this is the directory the user will land in. Default is `/app`.

### FLAG_FILE
User can specify the path to the flag file. Needs to be an absolute value as the container will set `chattr +i` on this file. Default is `/app/flag.txt`. In case the flag_file is random, chattr won't work place but file will exist.

| **NOTE**: There is a `FLAG_FILE_SYMLINK` environment variable, which isn't set by default, but if set, will generate a symlink for the flag in `/app/flag.txt` if `FLAG_FILE` is not `/app/flag.txt`.

| **NOTE**: When using `theflash2k/pwn-chal:windows`, make sure to put flag in `/app/flag.txt` or set the `FLAG_FILE` accordingly. Randomly generated flag files may not work as the flag will be copied from `/app/flag.txt` or `$FLAG_FILE` to `C:\flag.txt`

### OVERRIDE_USER
By default, the binaries will run in the context of `ctf-player` user. This can be overriden by `OVERRIDE_USER` variable. It can be a valid user. But, if the user doesn't exist, it will default to `root`.

### SETUID_USER
This environment variable will change owner and group of `CHAL_NAME` to `SETUID_USER` and then give it `suid` permissions. And will run as `OVERRIDE_USER`. Permission set is `4755`. if `SETUID_USER` doesn't exist, it will default to `root`.

| **NOTE**: When the `SETUID_USER` is set, `FLAG_FILE` will automatically be set to `400`, i.e. `READ-ONLY` to `$SETUID_USER`. This can be overriden with the `FORCE_FLAG_RO` parameter. Just set that to any value except `y` and the flag will be `440`.

### REDIRECT_STDERR
This environment variable will simply allow redirection of stderr through the socket. By default it is set to `y`, meaning that stderr will also be redirected.

### NO_FLAG
This environment variable will simply remove the `$FLAG_FILE`. (Made this specifically for Showdown-based challenges where there's a submitter binary.)

### ADD_READFLAG
This environment variable will set the 

### ROOT_ONLY_FLAG
This will set the flag to be read only by root user and no one else. The use-case for this particular flag is when we're trying to use a SUID `readflag` binary. Default `n`

### OUTBOUND_BLOCK
This blocks all the outbound connection. This is done using `iptables` so `CAP_NET_ADMIN` is required for the running container. If it is not provided, it doesn't SOFT-EXIT, but rather continues anyways. (Default=`y`)

### POW
Proof of Work. The value can be between 0-256. Default is `0`. 256 means HAAARD. Usually, you go for `25-32`.
> The POW was originally implemented by HXPCTF team. You can see in [pow](utilities/pow/pow) script

---

Environment variables may also be specified with the docker run command:
```bash
docker run -it --rm -e PORT=5012 -p 54251:5012 -e BASE=socat theflash2k/pwn-chal:latest
```

| **NOTE**: If no `CHAL_NAME` is provided, the default binary will run on the specified port and upon connecting, you'll get the following message:

```
pwn-chal container successfully deployed. Please setup your challenge by specifying the CHAL_NAME environment variable and placing your binary in /app.
Regards,
TheFlash2k
```

## Image-specific details

## Kernel:

For the kernel image, I decided to use QEMU under-the-hood. You can modify the following variables

### KASLR:
By default, KASLR (Kernel Address Space Layout Randomization) is set to `1`, i.e. it will be enabled. You can modify it by setting either `0` or `1` .

### KPTI:
By default, KPTI (Kernel Page Table Isolation) is set to `1`, i.e. it will be enabled. You can modify it by setting either `0` or `1` .

### SMEP:
By default, SMEP (Supervisor Mode Execution Prevention) is set to `1`, i.e. it will be enabled. You can modify it by setting either `0` or `1` .

### SMAP:
By default, SMAP (Supervisor Mode Access Prevention) is set to `1`, i.e. it will be enabled. You can modify it by setting either `0` or `1` .

### PANIC_ON_OOPS:
By default, Panic on OOPS is set to `1`, i.e. it will be enabled. You can modify it by setting either `0` or `1` .

### MODE:
`MODE` specifies how your payload will be downloaded/placed inside the vm. There are two available options:

- remote: This prompts the user to enter a URL from which the exploit will be downloaded. [DEFAULT]
- stdin: This prompts the user to enter a base64 encoded payload and then decodes it and stores it inside the vm.

### VM_MEMORY:
The amount of RAM that will be allocated to the virtual machine

### INITRAMFS:
The INITRAMFS file name. This file MUST be stored at `/app`. 
Default name is: `initramfs.cpio.gz`.

### KERNEL:
The name of the KERNEL. This file MUST be stored at `/app`.
Default name is: `vmlinuz`

### CPU:
The CPU that will be passed to the underlying qemu. There are two available options:
- `qemu64` [DEFAULT]
- `kvm64`

### SMP:
The CPU threads/cores defined in SMP will be passed directly.
By default it is set to `1`.

## Windows

Since the `windows` machine uses `wine` under the hood to run the binaries and `xvfb` to emulate a virtual display, following variables can be modified:

### WINEARCH:

This will let wine know whether the `CHAL_NAME` binary is a `x86` or `x64` binary.

### WINEPREFIX:

This is the folder that contains the wine configurations, if the configurations do not already exist, they will take around 10-15 seconds to generate the entire configurations. By default, `$RUN_AS/.wine` is set as the WINEPREFIX and upon each container start, the configs are automatically generated.

### WIN_DEBUG:

This is a custom variable, if set to any value, it will use `ynetd` to serve the `wine`-served binary and upon crash, it will show the debug logs to the user on the connection. If you want to see detailed logs, you can also set the `REDIRECT_STDERR=y` so that all the stderr logs are also passed through the socket. However, this should only be used when trying a challenge locally.

| **NOTE**: Since ASLR is disabled by default in the wine configuration, all `ASLR` related challenges might not work as expected.

## ARM & ARM64

In order to run the `arm` and `arm64` containers, you need to run the following command on the host first:

```bash
# Install the qemu packages
sudo apt-get install qemu binfmt-support qemu-user-static

# This step will execute the registering scripts
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
```

For debugging, you can set the following environment variable:

### QEMU_GDB_PORT

This port will be passed to the underlying `qemu-arm` command and will enable remote GDB debugging on the specified port.

| **NOTE**: When debugging is enabled, the container will run, and run the GDB port on the specified port, and since the program will run in a `while [[ 1 ]]` loop, it will continue to do so. However, the `stdin`, `stdout` and `stderr` aren't redirected to GDB, and therefore, running the container with `-d` option will not work the way you'd expect it to.

If you know how to fix it, please contact me, or a simple Pull Request with the fix ;).

A sample Dockerfile with debugging enabled:

```dockerfile
FROM theflash2k/pwn-chal:arm

ENV CHAL_NAME=baby-arm
ENV QEMU_GDB_PORT=7000

COPY ${CHAL_NAME} ${CHAL_NAME}
```

## Tags:

| Tag | Version | Usage |
| --- | --- | --- |
| latest | Ubuntu 25.04@sha256:5487c53773e2a8576213d1a2e18148fe167fabecfe7844724792f63041190d9d | [Github](https://github.com/TheFlash2k/pwn-chal/tree/master/samples/latest) |
| 2504 | Ubuntu 25.04@sha256:5487c53773e2a8576213d1a2e18148fe167fabecfe7844724792f63041190d9d | [Github](https://github.com/TheFlash2k/pwn-chal/tree/master/samples/2504) |
| 2410 | Ubuntu 24.10@sha256:cdf755952ed117f6126ff4e65810bf93767d4c38f5c7185b50ec1f1078b464cc | [Github](https://github.com/TheFlash2k/pwn-chal/tree/master/samples/2410) |
| 2404 | Ubuntu 24.04@sha256:4f1db91d9560cf107b5832c0761364ec64f46777aa4ec637cca3008f287c975e | [Github](https://github.com/TheFlash2k/pwn-chal/tree/master/samples/2404) |
| 2304 | Ubuntu 23.04@sha256:5a828e28de105c3d7821c4442f0f5d1c52dc16acf4999d5f31a3bc0f03f06edd | [Github](https://github.com/TheFlash2k/pwn-chal/tree/master/samples/2304) |
| 2204 | Ubuntu 22.04@sha256:3d1556a8a18cf5307b121e0a98e93f1ddf1f3f8e092f1fddfd941254785b95d7 | [Github](https://github.com/TheFlash2k/pwn-chal/tree/master/samples/2204) |
| 2004 | Ubuntu 20.04@sha256:8feb4d8ca5354def3d8fce243717141ce31e2c428701f6682bd2fafe15388214 | [Github](https://github.com/TheFlash2k/pwn-chal/tree/master/samples/2004) |
| 1804 | Ubuntu 18.04@sha256:152dc042452c496007f07ca9127571cb9c29697f42acbfad72324b2bb2e43c98 | [Github](https://github.com/TheFlash2k/pwn-chal/tree/master/samples/1804) |
| 1604 | Ubuntu 16.04@sha256:1f1a2d56de1d604801a9671f301190704c25d604a416f59e03c04f5c6ffee0d6 | [Github](https://github.com/TheFlash2k/pwn-chal/tree/master/samples/1604) |
| kernel | Ubuntu 25.04@sha256:9a302811bba2ae9533ddae0b563af29c112f1262329e508f13c0c532d5ba7c19 with QEMU | [Github](https://github.com/TheFlash2k/pwn-chal/tree/master/samples/kernel) |
| x86 | theflash2k/pwn-chal:latest with gcc-multilib installed for 32-bit support | [Github](https://github.com/TheFlash2k/pwn-chal/tree/master/samples/x86) |
| x86-cpp | theflash2k/pwn-chal:latest with g++-multilib installed for 32-bit support | [Github](https://github.com/TheFlash2k/pwn-chal/tree/master/samples/x86-cpp) |
| seccomp | theflash2k/pwn-chal:latest with libseccomp-dev installed | [Github](https://github.com/TheFlash2k/pwn-chal/tree/master/samples/seccomp) |
| py38 | python:3.8-slim-buster with my magic | [Github](https://github.com/TheFlash2k/pwn-chal/tree/master/samples/py38) |
| py311 | python:3.11-slim-buster with my magic | [Github](https://github.com/TheFlash2k/pwn-chal/tree/master/samples/py311) |
| crypto | python:3.11-slim-buster with Pycryptodome and my magic | [Github](https://github.com/TheFlash2k/pwn-chal/tree/master/samples/crypto) |
| sagemath | Using sagemath/sagemath:latest Docker image | [Github](https://github.com/TheFlash2k/pwn-chal/tree/master/samples/sagemath) |
| cpp | theflash2k/pwn-chal:latest with libstdc++ for C++ support | [Github](https://github.com/TheFlash2k/pwn-chal/tree/master/samples/cpp) |
| arm | 25.04@sha256:5487c53773e2a8576213d1a2e18148fe167fabecfe7844724792f63041190d9d with QEMU [Also with GDB Remote Debugging] | [Github](https://github.com/TheFlash2k/pwn-chal/tree/master/samples/arm) |
| arm64 | 25.04@sha256:5487c53773e2a8576213d1a2e18148fe167fabecfe7844724792f63041190d9d with QEMU [Also with GDB Remote Debugging] | [Github](https://github.com/TheFlash2k/pwn-chal/tree/master/samples/arm64) |
| windows | Ubuntu 20.04@sha256:8feb4d8ca5354def3d8fce243717141ce31e2c428701f6682bd2fafe15388214 with WINE and XVFB | [Github](https://github.com/TheFlash2k/pwn-chal/tree/master/samples/windows) |

## Known Bugs:

- Both ARM/ARM64 and Windows do not have `ASLR` and `PIE`, so the stack and library addresses are always constant.