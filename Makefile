GO      ?= go
PROMU   ?= $(shell $(GO) env GOBIN)/promu

PREFIX                  ?= $(shell pwd)
BIN_DIR                 ?= $(shell pwd)
DOCKER_IMAGE_NAME       ?= fluentd_process_exporter
DOCKER_IMAGE_TAG        ?= $(subst /,-,$(shell git rev-parse --abbrev-ref HEAD))

all: build

build: promu
	@echo ">> building binaries"
	@$(GO) mod vendor
	@$(PROMU) build --prefix $(PREFIX)

docker:
	@echo ">> building docker image"
	@docker build -t "$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG)" .

clean:
	rm -f fluentd_process_exporter

promu:
	@GOOS=$(shell uname -s | tr A-Z a-z) \
	GOARCH=$(subst x86_64,amd64,$(patsubst i%86,386,$(shell uname -m))) \
	$(GO) install github.com/prometheus/promu@latest

.PHONY: all build tarball docker promu
