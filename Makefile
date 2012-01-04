build:
	@find src -name '*.coffee' | xargs coffee -c -o lib
	@find test -name '*.coffee' | xargs coffee -c -o test/lib

test: build
	@mocha test/lib/twix.spec.js