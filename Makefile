BASE_IMG=theflash2k/pwn-chal
VERSIONS = latest kernel 2504 2410 2404 2304 2204 2004 1804 1604 cpp python python3 py313 py311 py38 seccomp x86 x86-cpp crypto sagemath arm arm64 windows

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

	@if [ ! -z "$$PUSH" ]; then \
		echo "Pusing $(BASE_IMG):$(VERSION) to Docker Hub"; \
		docker push "$(BASE_IMG):$(VERSION)" ; \
	fi