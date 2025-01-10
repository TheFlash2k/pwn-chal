# This pow-solver was found in hxp's custom ynetd implementation https://hxp.io/assets/data/code/ctf-ynetd-2024.12.31.tar.xz

all: pow-solver.cpp
	g++ \
		-std=c++11 -pedantic -Wall -Wextra -Werror \
		-O2 -funroll-loops \
		pow-solver.cpp \
		-lcrypto -lpthread \
		-lcrypto -lz -ldl -static-libgcc \
		-static \
		-o pow-solver
clean:
	rm -f pow-solver