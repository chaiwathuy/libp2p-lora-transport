# cleanup dependencies and download missing ones
.PHONY: deps
deps:
	go mod tidy
	go mod download

# run dependency cleanup, followed by updating the patch version
.PHONY: deps-update
deps-update: deps
	go get -u=patch
	
# run tests
.PHONY: tests
tests:
	go test -race -cover -count 1 ./...

# run standard go tooling for better rcode hygiene
.PHONY: tidy
tidy: imports fmt
	go vet ./...
	golint ./...

# automatically add missing imports
.PHONY: imports
imports:
	find . -type f -name '*.go' -exec goimports -w {} \;

# format code and simplify if possible
.PHONY: fmt
fmt:
	find . -type f -name '*.go' -exec gofmt -s -w {} \;

verifiers: staticcheck

staticcheck:
	@echo "Running $@ check"
	@GO111MODULE=on ${GOPATH}/bin/staticcheck ./...


.PHONY: arduino-deps
arduino-deps:
	sudo apt install arduino-mk python-serial -y

# dragino lora testing
# Single lora testing app

CC=gcc
CFLAGS=-c -O -W -Wextra -Werror -Wall -ansi -pedantic
LIBS=-lwiringPi -lpthread

dragino_raspberry: main.o
	$(CC) main.o  $(LIBS) -o dragino_raspberry

main.o:
	$(CC) $(CFLAGS) ./src/dragino/main.c

clean:
	rm *.o dragino_lora_app	

build-cgo:
	CGO_CFLAGS_ALLOW='.*' go build -o lol ./src/dragino/cmd/dragino/main.go