.PHONY: fastychain android ios fastychain-cross swarm evm all test clean
.PHONY: fastychain-linux fastychain-linux-386 fastychain-linux-amd64 fastychain-linux-mips64 fastychain-linux-mips64le
.PHONY: fastychain-linux-arm fastychain-linux-arm-5 fastychain-linux-arm-6 fastychain-linux-arm-7 fastychain-linux-arm64
.PHONY: fastychain-darwin fastychain-darwin-386 fastychain-darwin-amd64
.PHONY: fastychain-windows fastychain-windows-386 fastychain-windows-amd64
.PHONY: docker release

GOBIN = $(shell pwd)/build/bin
GO ?= latest

# Compare current go version to minimum required version. Exit with \
# error message if current version is older than required version.
# Set min_ver to the mininum required Go version such as "1.12"
min_ver := 1.12
ver = $(shell go version)
ver2 = $(word 3, ,$(ver))
cur_ver = $(subst go,,$(ver2))
ver_check := $(filter $(min_ver),$(firstword $(sort $(cur_ver) \
$(min_ver))))
ifeq ($(ver_check),)
$(error Running Go version $(cur_ver). Need $(min_ver) or higher. Please upgrade Go version)
endif

fastychain:
	cd cmd/fastychain; go build -o ../../bin/fastychain
	@echo "Done building."
	@echo "Run \"bin/fastychain\" to launch fastychain."

bootnode:
	cd cmd/bootnode; go build -o ../../bin/fastychain-bootnode
	@echo "Done building."
	@echo "Run \"bin/fastychain-bootnode\" to launch fastychain."

docker:
	docker build -t x256free/fastychain .

all: bootnode fastychain

release:
	./release.sh

install: all
	cp bin/fastychain-bootnode $(GOPATH)/bin/fastychain-bootnode
	cp bin/fastychain $(GOPATH)/bin/fastychain

android:
	build/env.sh go run build/ci.go aar --local
	@echo "Done building."
	@echo "Import \"$(GOBIN)/fastychain.aar\" to use the library."

ios:
	build/env.sh go run build/ci.go xcode --local
	@echo "Done building."
	@echo "Import \"$(GOBIN)/fastychain.framework\" to use the library."

test:
	go test ./...

clean:
	rm -fr build/_workspace/pkg/ $(GOBIN)/*

# The devtools target installs tools required for 'go generate'.
# You need to put $GOBIN (or $GOPATH/bin) in your PATH to use 'go generate'.

devtools:
	env GOBIN= go get -u golang.org/x/tools/cmd/stringer
	env GOBIN= go get -u github.com/kevinburke/go-bindata/go-bindata
	env GOBIN= go get -u github.com/fjl/gencodec
	env GOBIN= go get -u github.com/golang/protobuf/protoc-gen-go
	env GOBIN= go install ./cmd/abigen
	@type "npm" 2> /dev/null || echo 'Please install node.js and npm'
	@type "solc" 2> /dev/null || echo 'Please install solc'
	@type "protoc" 2> /dev/null || echo 'Please install protoc'

# Cross Compilation Targets (xgo)

fastychain-cross: fastychain-linux fastychain-darwin fastychain-windows fastychain-android fastychain-ios
	@echo "Full cross compilation done:"
	@ls -ld $(GOBIN)/fastychain-*

fastychain-linux: fastychain-linux-386 fastychain-linux-amd64 fastychain-linux-arm fastychain-linux-mips64 fastychain-linux-mips64le
	@echo "Linux cross compilation done:"
	@ls -ld $(GOBIN)/fastychain-linux-*

fastychain-linux-386:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/386 -v ./cmd/fastychain
	@echo "Linux 386 cross compilation done:"
	@ls -ld $(GOBIN)/fastychain-linux-* | grep 386

fastychain-linux-amd64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/amd64 -v ./cmd/fastychain
	@echo "Linux amd64 cross compilation done:"
	@ls -ld $(GOBIN)/fastychain-linux-* | grep amd64

fastychain-linux-arm: fastychain-linux-arm-5 fastychain-linux-arm-6 fastychain-linux-arm-7 fastychain-linux-arm64
	@echo "Linux ARM cross compilation done:"
	@ls -ld $(GOBIN)/fastychain-linux-* | grep arm

fastychain-linux-arm-5:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm-5 -v ./cmd/fastychain
	@echo "Linux ARMv5 cross compilation done:"
	@ls -ld $(GOBIN)/fastychain-linux-* | grep arm-5

fastychain-linux-arm-6:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm-6 -v ./cmd/fastychain
	@echo "Linux ARMv6 cross compilation done:"
	@ls -ld $(GOBIN)/fastychain-linux-* | grep arm-6

fastychain-linux-arm-7:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm-7 -v ./cmd/fastychain
	@echo "Linux ARMv7 cross compilation done:"
	@ls -ld $(GOBIN)/fastychain-linux-* | grep arm-7

fastychain-linux-arm64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm64 -v ./cmd/fastychain
	@echo "Linux ARM64 cross compilation done:"
	@ls -ld $(GOBIN)/fastychain-linux-* | grep arm64

fastychain-linux-mips:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mips --ldflags '-extldflags "-static"' -v ./cmd/fastychain
	@echo "Linux MIPS cross compilation done:"
	@ls -ld $(GOBIN)/fastychain-linux-* | grep mips

fastychain-linux-mipsle:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mipsle --ldflags '-extldflags "-static"' -v ./cmd/fastychain
	@echo "Linux MIPSle cross compilation done:"
	@ls -ld $(GOBIN)/fastychain-linux-* | grep mipsle

fastychain-linux-mips64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mips64 --ldflags '-extldflags "-static"' -v ./cmd/fastychain
	@echo "Linux MIPS64 cross compilation done:"
	@ls -ld $(GOBIN)/fastychain-linux-* | grep mips64

fastychain-linux-mips64le:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mips64le --ldflags '-extldflags "-static"' -v ./cmd/fastychain
	@echo "Linux MIPS64le cross compilation done:"
	@ls -ld $(GOBIN)/fastychain-linux-* | grep mips64le

fastychain-darwin: fastychain-darwin-386 fastychain-darwin-amd64
	@echo "Darwin cross compilation done:"
	@ls -ld $(GOBIN)/fastychain-darwin-*

fastychain-darwin-386:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=darwin/386 -v ./cmd/fastychain
	@echo "Darwin 386 cross compilation done:"
	@ls -ld $(GOBIN)/fastychain-darwin-* | grep 386

fastychain-darwin-amd64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=darwin/amd64 -v ./cmd/fastychain
	@echo "Darwin amd64 cross compilation done:"
	@ls -ld $(GOBIN)/fastychain-darwin-* | grep amd64

fastychain-windows: fastychain-windows-386 fastychain-windows-amd64
	@echo "Windows cross compilation done:"
	@ls -ld $(GOBIN)/fastychain-windows-*

fastychain-windows-386:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=windows/386 -v ./cmd/fastychain
	@echo "Windows 386 cross compilation done:"
	@ls -ld $(GOBIN)/fastychain-windows-* | grep 386

fastychain-windows-amd64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=windows/amd64 -v ./cmd/fastychain
	@echo "Windows amd64 cross compilation done:"
	@ls -ld $(GOBIN)/fastychain-windows-* | grep amd64
