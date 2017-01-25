$.plugin
	provides: "synth"
	depends: "StateMachine, type, dom"
, ->
	class SynthMachine extends $.StateMachine
		common = # a common subset of rules used in many states
			"#":  -> 2
			".":  -> 3
			"[":  -> 4
			'"':  -> 6
			"'":  -> 7
			" ":  -> @emitText()
			"\t": -> @emitText()
			"\n": -> @emitText()
			"\r": -> @emitText()
			",":  -> @emitNodeAndReparent @fragment
			"+":  -> @emitNodeAndReparent @cursor.parentNode ? @fragment
			eof:  -> @emitText()
		no_eof =
			eof: -> @emitError("Unexpected end of input")

		#define accum(s,k) { def: (c) -> k += c; s }
		o = (a...) -> $.extend a...
		constructor: (debug) ->
			debug = true
			super [
				enter:   ->
						@tag = @id = @cls = @attr = @val = @text = ""
						@attrs = {}
						1
				o accum(1, @tag), common
				o accum(2, @id), common
				o accum(3, @cls), common,
					enter: -> @cls += (@cls.length and " " or ""); 3
					".":   -> @cls += " "; 3
				o accum(4, @attr), no_eof,
					"=":   -> 5
					"]":   -> @attrs[@attr] = @val; @attr = @val = ""; 1
				o accum(5, @val), no_eof,
					"]":   -> @attrs[@attr] = @val; @attr = @val = ""; 1
				o accum(6, @text), no_eof,
					'\\':  -> 8
					'"':   -> @emitText()
				o accum(7, @text), no_eof,
					'\\':  -> 9
					"'":   -> @emitText()
				o accum(6, @text), no_eof
				o accum(7, @text), no_eof
			], debug
			@reset()
		reset: ->
			@fragment = @cursor = document.createDocumentFragment()
			@tag = @id = @cls = @attr = @val = @text = ""
			@attrs = {}
		emitError: (msg) -> throw new Error "#{msg}: #{@input}"
		emitNodeAndReparent: (nextCursor) ->
			if @tag
				@cursor.appendChild node = $.extend document.createElement(@tag)
				@id not in ["",null,undefined] and node.id = @id
				@cls not in ["",null,undefined] and node.className = @cls
				node.setAttribute(k, v) for k,v of @attrs
			@cursor = node and (nextCursor or node) or (nextCursor or @cursor)
			0
		htmlType = $.type.lookup("<html>")
		emitText: ->
			# flush the current node into the output fragment
			@emitNodeAndReparent()
			# then add a child and continue parsing
			@text?.length \
				and @cursor.appendChild htmlType.node(@text) \
				or @text = ""
			0


	machine = new SynthMachine()
	return {
		$:
			synth: (expr) ->
				# .synth(expr) - create DOM nodes to match a simple css expression
				machine.reset()
				machine.run(expr)
				$ if machine.fragment.childNodes.length is 1 then machine.fragment.childNodes[0]
				else machine.fragment
	}
