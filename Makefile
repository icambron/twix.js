build:
	@rm -rf bin/twix/*
	@ls src/*.coffee | xargs coffee -c -o bin/twix
	@ls src/lang/*.coffee | xargs coffee -c -o bin/twix/lang
	@cat bin/twix/lang/*.js > bin/twix/lang/langs.js
	@find test -name '*.coffee' | xargs coffee -c -o test/bin
	@cp lib/*.js bin/
	@node_modules/uglify-js/bin/uglifyjs bin/twix/twix.js > bin/twix/twix.min.js
	@node_modules/uglify-js/bin/uglifyjs bin/twix/lang/langs.js > bin/twix/lang/langs.min.js

test: build
	@node_modules/mocha/bin/mocha --reporter spec test/bin/twix.spec.js
