ifeq ($(shell uname -s), Darwin)
  seder := sed -i ".bak"
else
  seder := sed -i
endif

VER=$(shell grep version package.json | sed "s/[a-z \":,]*//g")

build: directories
	@find src -name '*.coffee' | xargs node_modules/.bin/coffee -c -o bin
	@find test -name '*.coffee' | xargs node_modules/.bin/coffee -c -o test/bin

	@./node_modules/uglify-js/bin/uglifyjs -o bin/twix.min.js bin/twix.js
	@./node_modules/uglify-js/bin/uglifyjs -o bin/locale.min.js bin/locale.js

	@$(seder) "s/  \"version\": [0-9.:\",]*/  \"version\": \"${VER}\",/g" bower.json
	@$(seder) "s/  \"version\": [0-9.:\",]*/  \"version\": \"${VER}\",/g" component.json
	@$(seder) "s/  version: [0-9.:\",]*/  version: \"${VER}\",/g" package.js

configure:
	@npm install
	@git submodule update --init --recursive

directories:
	@mkdir -p bin test/bin

bench: build
	@node test/bin/twix.bench.js

test: build
	@./node_modules/mocha/bin/mocha --reporter spec test/bin/twix.spec.js
