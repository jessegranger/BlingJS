[$, assert] = require './setup'

testCases =
	"div": "<div/>"
	"div div": "<div><div/></div>"
	"div  div": "<div><div/></div>"
	"div.foo": '<div class="foo"/>'
	"div.foo.bar": '<div class="foo bar"/>'
	"div#foo": '<div id="foo"/>'
	"div#foo.bar": '<div id="foo" class="bar"/>'
	"div.bar#foo": '<div id="foo" class="bar"/>'
	"div[data-foo=bar]": '<div data-foo="bar"/>'
	"div[data-foo=bar].baz": '<div class="baz" data-foo="bar"/>'
	"div[data-foo=bar]#baz": '<div id="baz" data-foo="bar"/>'
	"div[data-foo=bar][baz=zap]": '<div data-foo="bar" baz="zap"/>'
	"div, div": '<div/><div/>'
	"div, span": '<div/><span/>'
	"div + span": '<div/><span/>'
	"div, br, p div + span": "<div/><br/><p><div/><span/></p>"
	"p div + span, br, div": "<p><div/><span/></p><br/><div/>"
	"p 'text'": "<p>text</p>"

describe ".synth", ->
	it "exists", ->
		assert.equal (typeof $.synth), 'function'
	it "passes many test cases", ->
		for k, v of testCases
			s = $.synth(k).map($.toString).join(', ')
			assert.equal s, v, "#{k} should produce #{v}, not #{s}"

