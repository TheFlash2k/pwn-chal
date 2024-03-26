IMG=pwn-chal:x86-cpp-sample

all: chal container
chal:
	g++ -o test test.cpp -m32 -w
container:
	docker build -t $(IMG) .
run:
	docker run -it --name pwnchal --rm -p31337:8000 $(IMG)