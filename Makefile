PWD=$$(pwd)
SCRIPT_DIR=$(shell cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PROJ_ROOT=$(SCRIPT_DIR)
TOOLS_DIR=$(PROJ_ROOT)/tools

all: dev

.PHONY:
init:
	npm install

.PHONY:
dev:
	npm run dev

.PHONY:
build:
	npm run build

.PHONY:
clean:
	git clean -fdx
