# Proof-of-Work

This proof-of-work code is from [hxpCTF](https://hxp.io/assets/data/code/ctf-ynetd-2024.12.31.tar.xz)'s custom ynetd implementation.

The PoW script itself is inspired/less copy-pasta of [PWN.RED](https://pwn.red/pow)'s PoW script.

Since I was unable to make it work statically, I decided to compile it, patch the binary using patchelf and just provided all the dependencies in a `~4.0MB` archive which will be downloaded automatically.

> My ynetd implementation is based on the original ynetd and just the PoW portion from hxp. The rest is some tweaks.