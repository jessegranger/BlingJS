$.plugin
	provides: "synth"
	depends: "StateMachine, type, dom"
, ->

	# A SynthMachine is a StateMachine that consumes CSS-like strings,
	# and produces a DOM fragment to match the string.
	class SynthMachine extends $.StateMachine
		common = # common states used in many rules below
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
		rule = (a...) -> $.extend a...
		constructor: ->
			super [
				enter:   ->
						@tag = @id = @cls = @attr = @val = @text = ""
						@attrs = {}
						1
				rule accum(1, @tag), common
				rule accum(2, @id), common
				rule accum(3, @cls), common,
					enter: -> @cls += (@cls.length and " " or ""); 3
					".":   -> @cls += " "; 3
				rule accum(4, @attr), no_eof,
					"=":   -> 5
					"]":   -> @attrs[@attr] = @val; @attr = @val = ""; 1
				rule accum(5, @val), no_eof,
					"]":   -> @attrs[@attr] = @val; @attr = @val = ""; 1
				rule accum(6, @text), no_eof,
					'\\':  -> 8
					'"':   -> @emitText()
				rule accum(7, @text), no_eof,
					'\\':  -> 9
					"'":   -> @emitText()
				rule accum(6, @text), no_eof
				rule accum(7, @text), no_eof
			]
			@reset()
		reset: ->
			@fragment = @cursor = document.createDocumentFragment()
			@tag = @id = @cls = @attr = @val = @text = ""
			@attrs = {}
			@
		emitError: (msg) -> throw new Error "#{msg}: #{@input}"
		emitNodeAndReparent: (nextCursor) ->
			if @tag
				attrs = {}
				if @id? then attrs.id = @id
				if @cls? then attrs.className = @cls
				@cursor.appendChild node = $.extend document.createElement(@tag), attrs
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
	return $: synth: (expr) ->
		# .synth(expr) - create DOM nodes to match a simple css expression
		f = machine.reset().run(expr, 0).fragment
		return $(if f.childNodes.length is 1 then f.childNodes[0] else f)
