import sys

print("Well, hello there!")

with open("flag.txt", "r") as f:
    flag = f.read()

print(f"Here's the flag for you: {flag}")
print("Somethine for stderr too yk.", file=sys.stderr)