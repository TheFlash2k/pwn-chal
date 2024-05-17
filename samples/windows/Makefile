IMG := pwn-chal:windows-sample
CHAL := windows-test
CC := x86_64-w64-mingw32-gcc
FLAGS := -mwindows -w

.PHONY: all

all: chal container
chal:
	$(CC) -o $(CHAL) $(CHAL).c $(FLAGS)
container:
	docker build -t $(IMG) .
run:
	docker run -it --name pwnchal --rm -p31337:8000 $(IMG)
clean:
	rm -f $(CHAL)