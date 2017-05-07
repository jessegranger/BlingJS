$.plugin
	provides: "StateMachine"
	depends: "type, logger"
, ->
	_callAll = (f, c, arg) ->
		while (typeof f) is "function"
			f = f.call c, arg
		c.state = f	
	
	log = $.logger "[StateMachine]"

	$: StateMachine: class StateMachine # see plugins/synth for a complete usage example
		constructor: (table, state=null) ->
			table or= {}
			table[state] or= {}
			# state: property
			$.defineProperty @, "state",
				get: -> state
				set: (k) =>
					if k isnt state and k of table
						state = k
						_callAll table[state].enter, @
					else if k is null
						state = null
					state
			# row: property
			$.defineProperty @, "row",
				get: -> table[state]

		# static and instance versions of a state-changer factory
		goto: go = (k, reset=false) -> ->
			if reset # force enter: to trigger
				@state = null
			k
		@goto: go

		tick: (c) ->
			row = @row
			_callAll (row[c] ? row.def), @, c

		run: (inputs, initial_state=null) ->
			@state = initial_state
			@tick(c) for c in inputs # run all the inputs through the machine
			_callAll @row.eof, @ # run the eof: rule for the final state
			@

