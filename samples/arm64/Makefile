IMG=pwn-chal:arm64-sample

all: chal container
chal:
	aarch64-linux-gnu-gcc -o test test.c -w
container:
	docker build -t $(IMG) .
run:
	docker run -it --name pwnchal --rm -p31337:8000 $(IMG)
