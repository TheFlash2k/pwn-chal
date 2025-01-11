IMG=pwn-chal:sagemath-sample

build:
	docker build -t $(IMG) .
run:
	docker run -it --name pwnchal --rm -p31337:8000 $(IMG)
