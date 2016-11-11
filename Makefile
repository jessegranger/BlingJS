COFFEE=node_modules/.bin/coffee
UGLIFY=node_modules/.bin/uglifyjs
UGLIFY_OPTS?=--screw-ie8
JLDOM=node_modules/jldom

MOCHA=node_modules/.bin/mocha
MOCHA_FMT?=dot
MOCHA_OPTS=--compilers coffee:coffee-script/register \
	--globals document,window,Bling,$$,_ \
	-R ${MOCHA_FMT} \
	-s 500 \
	--bail

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

test: $(JLDOM) $(MOCHA) dist/bling.js $(filter-out setup.coffee, $(wildcard test/*.coffee))
	# All tests are passing.

test/bling.coffee: bling.coffee
	# Testing $<
	@$(MOCHA) $(MOCHA_OPTS) $@ && touch $@

test/%.coffee: plugins/%.coffee bling.coffee
	# Testing $<
	@$(MOCHA) $(MOCHA_OPTS) $@ && touch $@

site: dist/bling.js test $(UGLIFY)
	@git stash save &> /dev/null
	@git checkout site
	@sleep 1
	@cp dist/bling* js/
	@git show master:package.json > js/package.json
	@mkdir -p doc
	@git show master:doc/index.html > doc/index.html
	@(cd js \
		&& ../$(UGLIFY) bling.js -c --source-map bling.min.js.map --in-source-map bling.js.map  -m -r '$,Bling,window,document' --screw-ie8 -o bling.min.js \
		&& (gzip -f9c bling.min.js > bling.min.js.gz))
	@git add -f js/bling* js/package.json doc/*
	@git commit -am "make site" || true
	@sleep 1
	@git checkout master
	@sleep 1
	@git stash pop || true

dist/bling.js: dist/bling.coffee $(COFFEE)
	#  Compiling $< to $@...
	@(cd dist && ../node_modules/.bin/coffee -cm bling.coffee)

dist/bling.coffee: bling.coffee $(shell ls plugins/*.coffee | sort -f)
	#  Packing plugins into $@...
	@mkdir -p dist
	@cat $^ | $(GPP_FILTER) > $@

clean:
	rm -rf dist/*

$(MOCHA):
	npm install mocha

$(COFFEE):
	npm install coffee-script

$(JLDOM):
	npm install jldom

$(UGLIFY):
	npm install uglify-js

.PHONY: all clean release site test
