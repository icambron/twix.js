.PHONY: test

build:
	@cake build

test:
	@cake test

configure:
	@npm install
	@git submodule update --init --recursive
