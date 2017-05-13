[ $, assert ] = require './setup'

expect = (value, done) -> (err, result) -> assert.equal result, value; done()

describe "Render", ->
	describe "basic types as strings:", ->
		it "strings", (done) ->
			$.render("Hello").wait expect "Hello", done
			null
		it "numbers", (done) ->
			$.render(42).wait expect "42", done
			null
		it "floats", (done) ->
			$.render(1/3).wait expect "0.3333333333333333", done
			null
		describe "arrays of", ->
			it "strings", (done) ->
				$.render(["He","llo"]).wait expect "Hello", done
				null
			it "numbers", (done) ->
				$.render([1,2,3]).wait expect "123", done
				null
			it "arrays", (done) ->
				$.render([1,[2,[3]]]).wait expect "123", done
				null
			it "mixed", (done) ->
				$.render(["a",1,1/4,["c"]]).wait expect "a10.25c", done
				null
	describe "renders objects by type", ->
		it "can register new handlers", (done) ->
			$.render.register 'testing', (o, opts) -> "magic"
			$.render({ t: "testing" }).wait expect "magic", done
			null

		describe "built-in handlers", ->
			it "multi-lingual text", (done) ->
				$.render( { t: "text", EN: "Hello", FR: "Bonjour" }, { lang: "FR" }).wait(
					expect "Bonjour", done
				)
				null
			describe "scoped assignment", ->
				it "assigns variables", (done) ->
					$.render({ t: "let", name: "x", value: "foo", content: [
						{ t: "get", name: "x" }
					]}).wait expect "foo", done
					null
				it "supports nesting", (done) ->
					$.render(
						{ t: "let", name: "y", value: "foo", content: [
							{ t: "let", name: "y", value: "bar", content: [
								{ t: "get", name: "y" }
							] },
							{ t: "get", name: "y" }
						] }, { lang: "EN" }).wait expect "barfoo", done
					null
			it "anchor tags (links)", (done) ->
				$.render({ t:"link", href:"#home", content:"Home" }).wait(
					expect "<a href='#home'>Home</a>", done
				)
				null

		describe "basic async type:", ->
			it "promise", (done) ->
				$.render.register "promise-test", (o, opts) ->
					p = $.Promise()
					$.delay 200, -> p.resolve("OK")
					p
				$.render({ t: "promise-test" }).wait expect "OK", done
				null

		describe "nesting", ->
			it "case one", (done) ->
				$.render.register "nesting-one", (o, opts) -> $.render.reduce o.content, opts
				$.render({t:"nesting-one",content:{t:"text",EN:"Hello"}}).wait expect "Hello", done
				null
			it "case two", (done) ->
				$.render.register "nesting-two", (o, opts) -> $.render.reduce o.content, opts
				$.render({t:"nesting-two",content:[
					{t:"text",EN:"Hello"},
					" World"
				]}).wait expect "Hello World", done
				null
			it "case three", (done) ->
				$.render.register "nesting-three", (o, opts) -> $.render.reduce o.content, opts
				$.render({t:"nesting-three",content:[
					{t:"text",EN:"Hello"},
					p = $.Promise()
				]}).wait expect "Hello World", done
				p.resolve " World"
				null


