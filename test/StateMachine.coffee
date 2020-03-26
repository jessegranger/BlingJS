[$, assert] = require './setup'

describe ".StateMachine", ->
	it "is defined", ->
		assert $.StateMachine?
	it "is a function", ->
		assert.equal (typeof $.StateMachine), 'function'
	
	describe ".extractCode", ->
		test_cases = [
			[ "(#{((a) -> a).toString()})", "s=a;" ]
			[ "()=>{}", "" ]
			[ "(b)=>{return b}", "s=b" ] 
			[ "(c)=>{ /* {}*/ return c; }", "s=c;" ]
			[ "(a/*{*/)=>{return a;}", "s=a;" ]
		]
		for [f, s] in test_cases
			it ("supports: " + f), ->
				assert.equal $.StateMachine.extractCode(eval(f)), s
		null

	describe ".run()", ->
		Capper = {
			reset: -> @output = ""; Capper
			run: $.StateMachine [
				{ enter:   -> @output = "<<"; 1 }
				{
					def: (c) -> @output += c.toUpperCase(); 1
					eof:     -> @output += ">>"
				}
			]
		}
		it "starts in state 0", ->
			assert.equal Capper.reset().run(".").output, "<<.>>"
		it "reads input and rules from @STATE_TABLE", ->
			assert.equal Capper.reset().run("hello", 0).output, "<<HELLO>>"
		describe "empty input", ->
			emptyMachine = {
				reset: -> @enter = @eof = false; emptyMachine
				run: $.StateMachine [
					{
						enter: -> @enter = true; 0
						eof:   -> @eof = true; 0
					}
				]
			}
			it "triggers an eof rule in state 0", ->
				assert emptyMachine.reset().run("").eof
			it "triggers an enter rule in state 0", ->
				assert emptyMachine.reset().run("").enter
