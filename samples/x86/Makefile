IMG=pwn-chal:x86-sample

all: chal container
chal:
	gcc -o test test.c -m32 -w
container:
	docker build -t $(IMG) .
run:
	docker run -it --name pwnchal --rm -p31337:8000 $(IMG)