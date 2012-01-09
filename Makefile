build:
	@find src -name '*.coffee' | xargs coffee -c -o lib
	@find test -name '*.coffee' | xargs coffee -c -o test/lib

test: build
	@mocha --reporter spec test/lib/twix.spec.js