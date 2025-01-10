IMG=pwn-chal:kernel-sample

all: container run
container:
	docker build -t $(IMG) .
run:
	docker run -it --cap-add NET_ADMIN --name pwnchal --rm -p31337:8000 $(IMG)
