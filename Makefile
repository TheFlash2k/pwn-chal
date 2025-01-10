BASE_IMG=theflash2k/pwn-chal
VERSIONS = latest kernel 2404 2304 2204 2004 1804 1604 cpp arm arm64 py311 py38 seccomp x86 x86-cpp windows crypto

.PHONY: all
all: $(VERSIONS)

$(VERSIONS):
	@$(MAKE) builder VERSION="$@"

builder:
	echo "Building $(BASE_IMG):$(VERSION)"
	@if [ -e "Dockerfile.$(VERSION)" ]; then \
        docker build -t "$(BASE_IMG):$(VERSION)" -f "Dockerfile.$(VERSION)" . ; \
    else \
        echo "Dockerfile for version $(VERSION) does not exist."; \
    fi
