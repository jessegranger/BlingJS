$.plugin
	provides: "StateMachine"
	depends: "type, logger"
, ->
	_callAll = (f, c, arg) ->
		while (typeof f) is "function"
			f = f.call c, arg
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
		@extractCode = (f, priorText='') -> 
			return "" unless f?
			s = f.toString() \
				.replace(/^\s+/,"") \
				.replace(/\r/g, "##R##") \
				.replace(/\n/g, "##N##") \
				.replace(/\/\*(.*)\*\//g, "") \
				.replace(/\/\/(.*)(##N##|##R##)*/g,"")
			if s.indexOf("function") is 0
				s = s.replace(/function [^{]+ *{\s*/,priorText)
			else if /\([^{]+ *=>\s*{/.test s
				s = s.replace(/\([^{]+ *{\s*/,priorText)
			return s \
				.replace(/return ([^;]+),(\d+)/, '$1;s=$2') \
				.replace('return ', 's = ') \
				.replace(/\s*}$/,'') \
				.replace(/;*(##N##|##R##)\s*/g,';') \
				.replace(/##R##/g, "\r") \
				.replace(/##N##/g, "\n") \
				.replace(/^\s+/,"") \
				.replace(/\s+$/,"") \
				? ""
		constructor: (table, debug=false) ->
			parse = null
			trace = debug and "$.log('state:',s,'i:',i,'c:',c);" or ""
			ret = "s=s|0;for(i=i|0;i<=d.length;i++){c=d[i]||'eof';#{trace}switch(s){"
			for state,rules of table 
				if 'enter' of rules # enter is a special rule because it does not consume input
					priorText = 'p=s;'
					# it injects the onEnter code into the top of the case code
					onEnter = StateMachine.extractCode(rules.enter, priorText)
					# $.log "extractCode from", rules.enter, " OUTPUT: ", onEnter
					# wrap it in a state-change detector
					onEnter = "if(s!==p){#{onEnter};if(s!==p){i--;break}}"
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
					_code = StateMachine.extractCode(_code, priorText).replace(/\r|\n/g,'') + ";break;"
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
