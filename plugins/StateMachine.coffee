$.plugin
	provides: "StateMachine"
	depends: "type, logger"
, ->
	_callAll = (f, c, arg) ->
		while (typeof f) is "function"
			f = f.call c, arg
		if $.is 'number', f
			c.state = f	

	keyEscapes =
		"\n": "n"
		"\r": "r"
		"\t": "t"
		"\\": "\\"
		"'": "'"
		'"': '"'
	escapeAsKey = (c) ->
		c of keyEscapes \
			and "\\" + keyEscapes[c] \
			or c
	
	log = $.logger "[StateMachine]"

	$: StateMachine: class StateMachine # see plugins/synth for a complete usage example
		constructor: (table, debug=false) ->
			parse = null
			trace = debug and "$.log('state:',s,'i:',i,'c:',c);" or ""
			extractCode = (f, priorText='') -> f?.toString().replace(/function [^{]+ {\s*/,priorText).replace('return ', 's = ').replace(/\s*}$/,'').replace(/;*\n\s*/g,';') ? ''
			ret = "s=s|0;for(i=i|0;i<=d.length;i++){c=d[i]||'eof';#{trace}switch(s){"
			for state,rules of table 
				if 'enter' of rules # enter is a special rule because it does not consume input
					priorText = 'p=s;'
					# it injects the onEnter code into the top of the case code
					onEnter = "if(s!==p){#{extractCode(rules.enter, priorText)};if(s!==p){i--;break}}"
				else
					onEnter = ""

				hasRules = Object.keys(rules).length > (if 'enter' of rules then 1 else 0)

				ret += unless hasRules
					"case #{state}:#{onEnter}break;\n"
				else
					"case #{state}:#{onEnter}switch(c){"

				for _c,_code of rules
					continue if _c is 'enter' # already handled
					# extract the code from the state handler
					_code = extractCode(_code, priorText).replace(/\r|\n/g,'') + ";break;"
					ret += switch _c
						when 'def' then "default:#{_code}"
						else            "case '#{escapeAsKey _c}':#{_code}"
				ret += hasRules \
					and "}break;" or ""
			ret += "}}return this;"
			try @run = (new Function "d", "s", "i", "p", "c", ret)
			catch err
				$.log "Failed to parse compiled machine: ", ret
				throw err
