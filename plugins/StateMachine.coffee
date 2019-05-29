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
	extractCode = (f, priorText='') ->
		return "" unless f?
		s = f.toString() \
			.replace(/^\s+/,"") \
			.replace(/\r/g, "##R##") \
			.replace(/\n/g, "##N##") \
			.replace(/\/\*(.*)\*\//g, "") \
			.replace(/\/\/(.*)(##N##|##R##)*/g,"")
		if s.indexOf("function") is 0
			s = s.replace(/function[^{]*{\s*/,priorText)
		else if /\([^{]+ *=>\s*{/.test s
			s = s.replace(/\([^{]+ *{\s*/,priorText)
		return s \
			.replace(/return ([^;]+),(\d+)/g, '$1;s=$2') \
			.replace(/return /g, 's=') \
			.replace(/\s*}$/,'') \
			.replace(/([{}\[\],\\\/+*-]*)(##N##|##R##)\s*/g,'$1') \
			.replace(/;*(##N##|##R##)\s*/g,';') \
			.replace(/##R##/g, "\r") \
			.replace(/##N##/g, "\n") \
			.replace(/^\s+/,"") \
			.replace(/\s+$/,"") \
			.replace(/\r|\n/g,'') \
			? ""

	compileStateMachine = (table, debug=false) ->
		parse = null
		nl = if debug then "\n" else ""
		trace = debug and "$.log('state:',s,'i:',i,'c:',c);" or ""
		ret = "s=s|0;for(i=i|0;i<=d.length;i++){c=d[i]||'eof';#{trace}switch(s){#{nl}"
		for state,rules of table
			if 'enter' of rules # enter is a special rule because it does not consume input
				priorText = "p=s;#{nl}"
				# it injects the onEnter code into the top of the case code
				onEnter = extractCode(rules.enter, priorText)
				# wrap it in a state-change detector
				onEnter = "#{nl}if(s!==p){#{onEnter};if(s!==p){i--;break}}"
			else
				onEnter = ""

			hasRules = Object.keys(rules).length > (if 'enter' of rules then 1 else 0)

			ret += "case #{state}:#{onEnter}" \
				+ (hasRules and "switch(c){" or "break;\n")

			for _c,_code of rules
				continue if _c is 'enter' # already handled
				# extract the code from the state handler
				ret += _c is 'def' and "default:" or "case '#{escapeAsKey _c}':"
				ret += extractCode(_code, priorText) + ";break;"
			ret += hasRules and "}break;" or ""
		ret += "}}return this;"
		ret = ret.replace(/\s+&&\s+/g, '&&') \
			.replace(/\s+\|\|\s+/g, '||') \
			.replace(/\s+([+*/=-]*=)\s+/g, '$1')
		try return (new Function "d", "s", "i", "p", "c", ret)
		catch err
			$.log "Failed to parse compiled machine: ", ret
			throw err

	compileStateMachine.extractCode = extractCode # expose to unit test directly

	$: StateMachine: compileStateMachine
