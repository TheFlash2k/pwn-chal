IMG=pwn-chal:seccomp-sample

all: chal container
chal:
	gcc -o seccomp-test seccomp-test.c -lseccomp -fno-stack-protector -no-pie -zexecstack -w
container:
	docker build -t $(IMG) .
run:
	docker run -it --name pwnchal --rm -p31337:8000 $(IMG)