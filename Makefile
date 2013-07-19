.PHONY: build
build:
	@jekyll build
	@cp -r build/* .
