[$, assert] = require './setup'

describe ".StateMachine", ->
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
			assert.equal new Capper().run("hello").output, "<<HELLO>>"
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
			it "triggers an eof rule in state 0 (when compiled)", ->
				assert new EmptyMachine().compile().run("").eof
			it "triggers an enter rule in state 0 (when compiled)", ->
				assert new EmptyMachine().compile().run("").enter
		describe ".compile()", ->
			it "works inline", ->
				assert.equal new Capper().compile().run('foo').output, "<<FOO>>"

