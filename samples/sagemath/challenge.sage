#!/usr/bin/sage -python

from sage.all import *
from hashlib import sha512

def get_flag() -> str:
    try:
        with open("/flag.txt", "rb") as f:
            FLAG = f.read().strip()
        return FLAG
    except:
        print("[ERROR] - Please contact an Administrator.")

if __name__ == "__main__":
	name = input("What's your name? ").encode()
	if sha512(name).hexdigest() == "680febf9b5fdf51a4254ca0e8a530fc75fb6184bd656de2f40dd58056de02ad30a2094c95ccb87a278ff7384a4bf87e692cdc92da2797745a6a97240e260dba3":
		print("Welcome, Mr. Ashfaq!")
		print(get_flag().decode())
	else:
		print("Who are you???")

	# Using a sage method for testing:
	x = randrange(1000)
	print(f"Generated random : {x}")