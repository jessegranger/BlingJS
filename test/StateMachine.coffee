[$, assert] = require './setup'

describe ".StateMachine", ->
	it "is defined", ->
		assert $.StateMachine?
	
	describe ".extractCode", ->
		test_cases = [
			[ ((a) -> a).toString(), "s=a;" ]
			[ "()=>{}", "" ]
			[ "(b)=>{return b}", "s=b" ] 
			[ "(c)=>{ /* {}*/ return c; }", "s=c;" ]
			[ "(a/*{*/)=>{return a;}", "s=a;" ]
		]
		for [f, s] in test_cases
			it "supports: " + f, ->
				assert.equal $.StateMachine.extractCode(eval(f)), s
		null

	it "allows subclassing to define machines", ->
		class T extends $.StateMachine
		t = new T
		assert $.is 'function', t.run
	describe ".run()", ->
		class Capper extends $.StateMachine then constructor: -> super [
			{ enter:   -> @output = "<<"; 1 }
			{
				def: (c) -> @output += c.toUpperCase(); 1
				eof:     -> @output += ">>"
			}
		]
		it "starts in state 0", ->
			assert.equal new Capper().run(".").output, "<<.>>"
		it "reads input and rules from @STATE_TABLE", ->
			assert.equal new Capper().run("hello", 0).output, "<<HELLO>>"
		describe "empty input", ->
			class EmptyMachine extends $.StateMachine then constructor: -> super [
				{
					enter: -> @enter = true; 0
					eof:   -> @eof = true; 0
				}
			]
			it "triggers an eof rule in state 0", ->
				assert new EmptyMachine().run("").eof
			it "triggers an enter rule in state 0", ->
				assert new EmptyMachine().run("").enter
