build:
	@rm -f bin/*
	@find src -name '*.coffee' | xargs coffee -c -o bin
	@find test -name '*.coffee' | xargs coffee -c -o test/bin
	@node_modules/uglify-js/bin/uglifyjs bin/twix.js > bin/twix.min.js

test: build
	@node_modules/mocha/bin/mocha --reporter spec test/bin/twix.spec.js

configure:
	@npm install
	@git submodule update --init --recursive
