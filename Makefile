build:
	@rm -rf bin/*
	@ls src/*.coffee | xargs coffee -c -o bin
	@ls src/lang/*.coffee | xargs coffee -c -o bin/lang
	@cat bin/lang/*.js > bin/lang/langs.js
	@find test -name '*.coffee' | xargs coffee -c -o test/bin
	@node_modules/uglify-js/bin/uglifyjs bin/twix.js > bin/twix.min.js
	@node_modules/uglify-js/bin/uglifyjs bin/lang/langs.js > bin/lang/langs.min.js

test: build
	@node_modules/mocha/bin/mocha --reporter spec test/bin/twix.spec.js

configure:
	@npm install
	@git submodule update --init --recursive
