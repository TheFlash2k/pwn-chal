IMG=pwn-chal:cpp-sample

all: chal container
chal:
	g++ -o test test.cpp -w
container:
	docker build -t $(IMG) .
run:
	docker run -it --name pwnchal --rm -p31337:8000 $(IMG)