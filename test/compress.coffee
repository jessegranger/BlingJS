
[$, assert] = require "./setup"

describe "Compress plugin", ->
	input = $.repeat($.random.string(64), 1024)
	describe "$.compress(text)", ->
		it "produces string output", ->
			assert (typeof $.compress input) is 'string'
		it "should not produce empty output", ->
			assert $.compress(input).length > 0
		it "unless the input is also empty", ->
			assert.equal $.compress(""), ""
		it "should shrink the input", ->
			assert $.compress(input).length < input.length
	describe "$.decompress(input)", ->
		output = $.compress(input)
		it "produces string output", ->
			assert (typeof $.decompress output) is 'string'
		it "should not produce empty output", ->
			assert $.decompress(output).length > 0
		it "unless the input is also empty", ->
			assert.equal $.decompress(""), ""
		it "should produce the orignal input", ->
			assert.equal $.decompress(output), input




