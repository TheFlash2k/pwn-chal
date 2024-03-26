#!/bin/bash

echo "[*] This is meant to run on the host, not the container."

sudo apt-get install qemu binfmt-support qemu-user-static
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes