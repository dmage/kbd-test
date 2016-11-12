KBDROOT ?= ~/kbd

all: help

help:
	@echo "Usage:"
	@echo ""
	@echo "    make ubuntu-16.04.img  - build virtual machine image"
	@echo "    make dump              - run dumpkeys for all keymaps"
	@echo "    make clean             - remove generated files"

ssh:
	mkdir -m 0700 ./ssh
	ssh-keygen -C root@kbd-test -f ./ssh/id_rsa -N ""

ubuntu-16.04.img: ssh
	./hack/build-vm.sh

build:
	mkdir -p ./bin
	KBDROOT=$(KBDROOT) ./hack/build-kbd.sh
	cp $(KBDROOT)/src/loadkeys $(KBDROOT)/src/dumpkeys ./bin/

dump: ubuntu-16.04.img
	./hack/dump.sh
	diff -dur ./stabledump ./dump && echo "Dump has no difference with stable version"

clean:
	rm -rf ./ubuntu-16.04.img ./ssh ./dump

.PHONY: dump clean
