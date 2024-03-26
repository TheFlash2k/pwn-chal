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
LOG_FILE
OVERRIDE_USER
SETUID_USER
REDIRECT_STDERR
```

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

### LOG_FILE
The absolute path of the file in which the logs will be stored. If not path is specified, only a file name; the logs will be stored in `/app/<file-name>`

### OVERRIDE_USER
By default, the binaries will run in the context of `ctf-player` user. This can be overriden by `OVERRIDE_USER` variable. It can be a valid user. But, if the user doesn't exist, it will default to `root`.

### SETUID_USER
This environment variable will change owner and group of `CHAL_NAME` to `SETUID_USER` and then give it `suid` permissions. And will run as `OVERRIDE_USER`. Permission set is `4755`. if `SETUID_USER` doesn't exist, it will default to `root`.

### REDIRECT_STDERR
This environment variable will simply allow redirection of stderr through the socket. By default it is set to `y`, meaning that stderr will also be redirected.

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

### ARM & ARM64

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
| latest | Ubuntu 22.04@sha256:f9d633ff6640178c2d0525017174a688e2c1aef28f0a0130b26bd5554491f0da | [Github](https://github.com/TheFlash2k/pwn-chal/tree/master/samples/latest) |
| 2204 | Ubuntu 22.04@sha256:f9d633ff6640178c2d0525017174a688e2c1aef28f0a0130b26bd5554491f0da | [Github](https://github.com/TheFlash2k/pwn-chal/tree/master/samples/2204) |
| 2004 | Ubuntu 20.04@sha256:80ef4a44043dec4490506e6cc4289eeda2d106a70148b74b5ae91ee670e9c35d | [Github](https://github.com/TheFlash2k/pwn-chal/tree/master/samples/2004) |
| 1804 | Ubuntu 18.04@sha256:152dc042452c496007f07ca9127571cb9c29697f42acbfad72324b2bb2e43c98 | [Github](https://github.com/TheFlash2k/pwn-chal/tree/master/samples/1804) |
| 1604 | Ubuntu 16.04@sha256:1f1a2d56de1d604801a9671f301190704c25d604a416f59e03c04f5c6ffee0d6 | [Github](https://github.com/TheFlash2k/pwn-chal/tree/master/samples/1604) |
| x86 | theflash2k/pwn-chal:latest with gcc-multilib installed for 32-bit support | [Github](https://github.com/TheFlash2k/pwn-chal/tree/master/samples/x86) |
| x86-cpp | theflash2k/pwn-chal:latest with g++-multilib installed for 32-bit support | [Github](https://github.com/TheFlash2k/pwn-chal/tree/master/samples/x86-cpp) |
| seccomp | theflash2k/pwn-chal:latest with libseccomp-dev installed | [Github](https://github.com/TheFlash2k/pwn-chal/tree/master/samples/seccomp) |
| py38 | python:3.8-slim-buster with my magic | [Github](https://github.com/TheFlash2k/pwn-chal/tree/master/samples/py38) |
| cpp | theflash2k/pwn-chal:latest with libstdc++ for C++ support | [Github](https://github.com/TheFlash2k/pwn-chal/tree/master/samples/cpp) |
| arm | Ubuntu 22.04@sha256:f9d633ff6640178c2d0525017174a688e2c1aef28f0a0130b26bd5554491f0da with QEMU [Also with GDB Remote Debugging] | [Github](https://github.com/TheFlash2k/pwn-chal/tree/master/samples/arm) |
| arm64 | Ubuntu 22.04@sha256:f9d633ff6640178c2d0525017174a688e2c1aef28f0a0130b26bd5554491f0da with QEMU [Also with GDB Remote Debugging] | [Github](https://github.com/TheFlash2k/pwn-chal/tree/master/samples/arm64) |
| mips | Not yet implemented | --- |
