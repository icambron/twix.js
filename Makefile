ifeq ($(shell uname -s), Darwin)
  seder := sed -i ".bak"
else
  seder := sed -i
endif

VER=$(shell grep version package.json | sed "s/[a-z \":,]*//g")

PATH := node_modules/.bin:$(PATH)
SHELL := /bin/bash

build: directories
	@find src -name '*.coffee' | xargs coffee -c -o dist
	@find test -name '*.coffee' | xargs coffee -c -o test

	@uglifyjs -o dist/twix.min.js dist/twix.js

	@$(seder) "s/  \"version\": [0-9.:\",]*/  \"version\": \"${VER}\",/g" bower.json
	@$(seder) "s/  \"version\": [0-9.:\",]*/  \"version\": \"${VER}\",/g" component.json
	@$(seder) "s/  version: [0-9.:\",]*/  version: \"${VER}\",/g" package.js

configure:
	@npm install

directories:
	@mkdir -p dist

bench: build
	@node test/twix.bench.js

test: build
	@mocha -R dot

lint: build
	@coffeelint src test

coverage: build
	@mocha --require blanket -R html-cov > test/coverage.html

coveralls: build
	@mocha --require blanket -R mocha-lcov-reporter | coveralls
