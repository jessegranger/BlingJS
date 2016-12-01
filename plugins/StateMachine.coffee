$.plugin
	provides: "StateMachine"
	depends: "type, logger"
, ->
	_callAll = (f, c, arg) ->
		while (typeof f) is "function"
			f = f.call c, arg
		if $.is 'number', f
			c.state = f	
	
	log = $.logger "[StateMachine]"

	$: StateMachine: class StateMachine # see plugins/synth for a complete usage example
		constructor: (@table) ->
			state = null
			$.defineProperty @, "state",
				set: (m) ->
					if m isnt state and m of @table
						_callAll @table[state = m].enter, @
					else if m is null
						state = null
					state
				get: -> state

		# static and instance versions of a state-changer factory
		goto: go = (m, reset=false) -> ->
			if reset # force enter: to trigger
				@state = null
			@state = m
		@goto: go

		tick: (c) ->
			row = @table[@state]
			return null unless row?
			_callAll (row[c] ? row.def), @, c

		run: (inputs) ->
			# run the enter: rule for state 0
			@state = 0
			# run all the inputs through the machine
			@tick(c) for c in inputs
			# run the eof: rule for the final state
			_callAll @table[@state].eof, @
			@

		# Once you have a working machine, you can compile it to bare JavaScript,
		# this inlines all the functions and states into a two-level set of switch statements.
		compile: ->
			parse = null
			extractCode = (f, priorText='') -> f?.toString().replace(/function [^{]+ {\s*/,priorText).replace('return ', 's = ').replace(/\s*}$/,'').replace(/;*\n\s*/g,';') ? ''
			ret = "s=0;for(i=0;i<=d.length;i++){c=d[i]||'eof';switch(s){"
			for state,rules of @table 
				if 'enter' of rules # enter is special because it does not consume input
					priorText = 'p=s;'
					onEnter = "if(s!==p){#{extractCode(rules.enter, priorText)} if(s!==p){i--;break;}}"
				else
					onEnter = ""

				hasRules = Object.keys(rules).length > (if 'enter' of rules then 1 else 0)

				ret += unless hasRules then "case #{state}:#{onEnter}break;\n"
				else "case #{state}:#{onEnter}switch(c){"

				for _c,_code of rules
					continue if _c is 'enter' # already handled
					# extract the code from the state handler
					_code = extractCode(_code, priorText).replace(/\r|\n/g,'') + " break;"

					ret += switch _c
						when "'"   then "case \"'\":#{_code}"
						when '"'   then "case '\"':#{_code}"
						when 'def' then "default:#{_code}"
						else            "case '#{_c}':#{_code}"
				ret += hasRules and "}break;" or ""
			ret += "}}return this;"
			@run = (new Function "d", "s", "i", "c", "p", ret)
			@
