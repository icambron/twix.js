ifeq ($(shell uname -s), Darwin)
  seder := sed -i ".bak"
else
  seder := sed -i
endif

VER=$(shell grep version package.json | sed "s/[a-z \":,]*//g")

build: directories
	@find src -name '*.coffee' | xargs node_modules/.bin/coffee -c -o dist
	@find test -name '*.coffee' | xargs node_modules/.bin/coffee -c -o test/dist

	@./node_modules/uglify-js/bin/uglifyjs -o dist/twix.min.js dist/twix.js

	@$(seder) "s/  \"version\": [0-9.:\",]*/  \"version\": \"${VER}\",/g" bower.json
	@$(seder) "s/  \"version\": [0-9.:\",]*/  \"version\": \"${VER}\",/g" component.json
	@$(seder) "s/  version: [0-9.:\",]*/  version: \"${VER}\",/g" package.js

configure:
	@npm install
	@git submodule update --init --recursive

directories:
	@mkdir -p dist test/dist

bench: build
	@node test/dist/twix.bench.js

test: build
	@./node_modules/mocha/bin/mocha --reporter spec test/dist/twix.spec.js
