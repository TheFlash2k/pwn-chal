BASE_IMG=theflash2k/pwn-chal
VERSIONS = latest 2204 2004 1804 1604 cpp arm arm64 py38 seccomp x86 x86-cpp

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
