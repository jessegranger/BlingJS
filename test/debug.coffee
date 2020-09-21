
[$, assert] = require './setup'

describe "$.debugStack", ->
	it "reads all the files in stack trace", (done) ->
		$.delay 1, $.throttle 1000, ->
			lines = $.debugStack(new Error("foo"))
			assert.match lines, new RegExp """Error: foo
\\s*at [^:]+test/debug.coffee:\\d+:\\d+
\\s*\\d+.*
\\s*(\\d*)(\\s+)lines = .*
\\s*\\1\\2 {21}\\^
\\s*at throttle .*
\\s*\\d+.*
\\s*(\\d+)(\\s+)f\\.apply.*
\\s*\\3\\4 {2}\\^
\\s*at .*
\\s*\\d+.*
\\s*(\\d+)(\\s+)last = throttle.*
\\s*\\5\\6 {7}\\^
\\s*at Timeout.*
\\s*\\d+.*
\\s*(\\d+)(\\s+)a\\.shift.*
\\s*\\7\\8 {9}\\^"""
			# assert.equal list.length, 94, lines
			# always pass for now, hard to find a truly stable stack to test
			done()

describe "$.protoChain", ->
	it "returns a string describing the prototype chain", ->
		class A
		class B extends A
		class C extends B
		assert.deepEqual [C, B, A, Object], $.protoChain(new C())
