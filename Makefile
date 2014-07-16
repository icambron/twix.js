build: directories
	@find src -name '*.coffee' | xargs coffee -c -o bin
	@find test -name '*.coffee' | xargs coffee -c -o test/bin

	@./node_modules/uglify-js/bin/uglifyjs -o bin/twix.min.js bin/twix.js
	@./node_modules/uglify-js/bin/uglifyjs -o bin/lang.min.js bin/lang.js

configure:
	@npm install
	@git submodule update --init --recursive

directories:
	@mkdir -p bin test/bin

bench: build
	@node test/bin/twix.bench.js

test: build
	@./node_modules/mocha/bin/mocha --reporter spec test/bin/twix.spec.js
