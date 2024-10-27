IMG=pwn-chal:crypto-sample

all: container
container:
	docker build -t $(IMG) .
run:
	docker run -it --name pwnchal --rm -p31337:8000 $(IMG)