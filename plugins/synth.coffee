$.plugin
	provides: "synth"
	depends: "StateMachine, type, dom"
, ->

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
	htmlType = $.type.lookup("<html>")
	rule = (a...) -> $.extend a...
	#define accum(s,k) { def: (c) -> k += c; s }
	synthMachine = {
		reset: ->
			@fragment = @cursor = document.createDocumentFragment()
			@tag = @id = @cls = @attr = @val = @text = ""
			@attrs = {}
			@
		emitError: (msg) -> throw new Error "#{msg}: #{@input}"
		emitNodeAndReparent: (nextCursor) ->
			if @tag?.length > 0
				node = document.createElement @tag
				@id?.length > 0 and node.id = @id
				@cls?.length > 0 and node.className = @cls
				@cursor.appendChild node
				node.setAttribute(k, v) for k,v of @attrs
			@cursor = node and (nextCursor or node) or (nextCursor or @cursor)
			0
		emitText: ->
			# flush the current node into the output fragment
			@emitNodeAndReparent()
			# then add a child and continue parsing
			@text?.length \
				and @cursor.appendChild htmlType.node(@text) \
				or @text = ""
			0
		run: $.StateMachine [
			enter:   ->
					@tag = @id = @cls = @attr = @val = @text = ""
					@attrs = {}
					1
			# state 1: accumulate into @tag, with common transitions
			rule accum(1, @tag), common
			# state 2: accumulate into @id, with common transitions
			rule accum(2, @id), common
			# state 3: accumulate into @cls, ... common ...
			rule accum(3, @cls), common,
				enter: -> @cls += (@cls.length and " " or ""); 3
				".":   -> @cls += " "; 3 # override common: add extra classes
			# state 4: accumulate into @attr (the k in "[k=v]")
			rule accum(4, @attr), no_eof,
				"=":   -> 5
				"]":   -> @attrs[@attr] = @val; @attr = @val = ""; 1
			# state 5: accumulate into @val (the v in "[k=v]")
			rule accum(5, @val), no_eof,
				"]":   -> @attrs[@attr] = @val; @attr = @val = ""; 1
			# state 6: accumulate into a #text node, from "
			rule accum(6, @text), no_eof,
				'\\':  -> 8 # start an escape
				'"':   -> @emitText()
			# state 7: accumulate into a #text node, from '
			rule accum(7, @text), no_eof,
				'\\':  -> 9 # start an escape
				"'":   -> @emitText()
			# state 8: skip an escaped character and go back to 6
			rule accum(6, @text), no_eof
			# state 9: skip an escaped charecter and go back to 7
			rule accum(7, @text), no_eof
		]
	}

	return $: synth: (expr) ->
		# .synth(expr) - create DOM nodes to match a simple css expression
		f = synthMachine.reset().run(expr, 0).fragment
		return $(if f.childNodes.length is 1 then f.childNodes[0] else f)
