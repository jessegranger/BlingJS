SHELL=/bin/bash
COFFEE=node_modules/.bin/coffee
UGLIFY=node_modules/.bin/uglifyjs
UGLIFY_OPTS?=--screw-ie8
JLDOM=node_modules/jldom

GPP=gpp
GPP_OPTS=-U '' '' '(' ',' ')' '(' ')' '\#' '' \
	-M '\#' '\n' ' ' ' ' '\n' '(' ')' \
	+c '\# ' '\n' \
	+c '\#\#\#' '\#\#\#' \
	+s '"' '"' "\\" \
	+s "'" "'" "\\" -n
GPP_FILTER=sed -E 's/^	*\# .*$$//g' | grep -v '^ *$$' | $(GPP) $(GPP_OPTS)


all: release

release: dist/bling.js

test: $(JLDOM) dist/bling.js $(filter-out setup.coffee, $(wildcard test/*.coffee))
	# All tests are passing.

test/%.coffee: plugins/%.coffee bling.coffee
	# Testing $<
	@$(COFFEE) $@ --bail --default && touch $@
	@echo

site: dist/bling.js test $(UGLIFY)
	# Stashing master...
	@git stash save &> /dev/null
	# Checking out site...
	@git checkout site &> /dev/null
	@sleep 1
	# Copy dist/ to js/
	@cp dist/bling* js/
	@git show master:package.json > js/package.json
	# Update documentation...
	@mkdir -p doc
	@git show master:doc/index.html > doc/index.html
	# Minify and compress...
	@(cd js \
		&& ../$(UGLIFY) bling.js -c -m -r '$,Bling,window,document' --screw-ie8 -o bling.min.js \
		&& (gzip -f9c bling.min.js > bling.min.js.gz)) > /dev/null
	# Commit to site branch...
	@git add -f js/bling* js/package.json doc/* &> /dev/null
	@git commit --no-gpg-sign -am "make site" &> /dev/null || true
	@sleep 1
	# Restoring master...
	@git checkout master &> /dev/null
	@sleep 1
	@git stash pop &> /dev/null || true

dist/bling.js: dist/bling.coffee $(COFFEE)
	#  Compiling $< to $@...
	@(cd dist && ../node_modules/.bin/coffee -cm bling.coffee)

dist/bling.coffee: bling.coffee $(shell ls plugins/*.coffee | sort -f)
	#  Packing plugins into $@...
	@mkdir -p dist
	@cat $^ | $(GPP_FILTER) > $@

dist/bling.min.js: dist/bling.js $(UGLIFY)
		(cd dist && \
			../$(UGLIFY) bling.js -c -m -r '$,Bling,window,document' \
				--screw-ie8 -o bling.min.js)

clean:
	rm -rf dist/*

$(MOCHA):
	npm install mocha

$(COFFEE):
	npm install coffeescript

$(JLDOM):
	npm install jldom

$(UGLIFY):
	npm install uglify-es

.PHONY: all clean release site test
