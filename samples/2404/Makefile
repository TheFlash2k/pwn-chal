IMG=pwn-chal:2404-sample

all: chal container
chal:
	gcc -o test test.c -w
container:
	docker build -t $(IMG) .
run:
	docker run -it --name pwnchal --rm -p31337:8000 $(IMG)