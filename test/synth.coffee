[$, assert] = require './setup'

testCases =
	"div": "<div/>"
	"div div": "<div><div/></div>"
	"div  div": "<div><div/></div>"
	"div.foo": '<div class="foo"/>'
	"div.foo.bar": '<div class="foo bar"/>'

runAllTestCases = ->
	for k, v of testCases
		s = $.synth.compiled(k).map($.toString).join(', ')
		assert.equal s, v, "Pattern: #{k} should produce #{v}, got: #{s}"
describe ".synth", ->
	it "exists", ->
		assert.equal (typeof $.synth), 'function'
	it "converts CSS to DOM fragments", ->
		assert.deepEqual $.synth('div').select('nodeName'), [ 'DIV' ]
	it "works the same when using the compiled version", ->
		assert.deepEqual $.synth.compiled('div').select('nodeName'), [ 'DIV' ]
	it "supports", runAllTestCases
	describe "when compiled", ->
		it "supports", runAllTestCases



