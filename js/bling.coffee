Object.keys or= (o) => (k for k of o)
Object.values or= (o) => (o[k] for k of o)
extend = (a, b...) =>
	for obj in b when obj
		a[k] = v for k,v of obj 
	a
Bling = (args...) ->
	"Bling:nomunge"
	if args.length is 1 
		args = $.type.lookup(args[0]).array(args[0])
	b = $.inherit Bling, args
	if args.length is 0 and args[0] isnt undefined
		i = 0
		i++ while args[i] isnt undefined
		b.length = i
	if 'init' of Bling 
		return Bling.init(b)
	return b
$ = Bling
$.global = do -> @
$.plugin = (opts, constructor) ->
	if not constructor
		constructor = opts
		opts = {}
	
	_t = @
	if "depends" of opts
		return _t.depends opts.depends, ->
			_t.plugin { provides: opts.provides }, constructor
	try
		if typeof (plugin = constructor?.call _t,_t) is "object"
			extend @, plugin.$
			delete plugin.$
			extend _t.prototype, plugin
			for key of plugin then do (key) ->
				_t[key] or= (a...) -> (_t.prototype[key].apply $(a[0]), a[1...])
			if opts.provides? then _t.provide opts.provides
	catch error
		console.error "plugin failed '#{_t.name}':", ($.debugStack ? $.identity ? (x) -> x) error.stack
	@
extend $, do ->
	waiting = []
	complete = {}
	commasep = /, */
	not_complete = (x) -> not (x of complete)
	incomplete = (n) ->
		(if (typeof n) is "string" then n.split commasep else n)
		.filter not_complete
	depends: (needs, func) ->
		if (needs = incomplete needs).length is 0 then func()
		else waiting.push (need) ->
			(needs.splice i, 1) if (i = needs.indexOf need) > -1
			return (needs.length is 0 and func)
		func
	provide: (needs, data) ->
		caught = []
		for need in incomplete needs
			complete[need] = i = -1
			while ++i < waiting.length 
				if (f = waiting[i] need) 
					waiting.splice i,1 
					try f data 
					catch err then caught.push(err) 
					i = -1 
		if caught.length > 0
			f = $.debugStack ? $.identity ? (x) -> x.stack
			caught.map(f).forEach(console.error.bind console)
		data
$.plugin
	depends: "core"
	provides: "async,series,parallel"
, ->
	return {
		series: (fin = $.identity) ->
			ret = $()
			todo = @length
			unless todo > 0
				fin.apply ret, ret
			else
				done = 0
				finish_one = (index) -> -> 
					ret[index] = arguments 
					if ++done >= todo then fin.apply ret, ret 
					else next done
					null
				do next = (i=0) => $.immediate => @[i] finish_one i
			@
		parallel: (fin = $.identity) ->
			ret = $()
			todo = @length
			unless todo > 0
				fin.apply ret, ret
			else
				done = 0
				finish_one = (index) -> -> 
					ret[index] = arguments
					if ++done >= todo
						fin.apply ret, ret
					null
				for i in [0...todo] by 1
					@[i] finish_one i
			@
	}
$.plugin
	provides: "cache, Cache"
	depends: "core, sortBy, logger"
, ->
	class EffCache
		log = $.logger "[LRU]"
		constructor: (@capacity = 1000, @defaultTtl = Infinity) ->
			@capacity = Math.max 0, @capacity
			@evictCount = Math.max 3, Math.floor @capacity * .1
			index = Object.create null
			order = []
			eff = (o) -> -o.r / o.w
			autoEvict = =>
				return unless @capacity > 0
				if order.length >= @capacity
					while order.length + @evictCount - 1 >= @capacity
						delete index[k = order.pop().k]
				null
			reIndex = (i, j) ->
				for x in [i..j] when 0 <= x < order.length
					index[order[x].k] = x
				null
			rePosition = (i) ->
				obj = order[i]
				j = $.sortedIndex order, obj, eff
				if j isnt i
					order.splice i, 1
					order.splice j, 0, obj
					reIndex i, j
				null
			noValue	= v: undefined
			$.extend @,
				has: (k) -> k of index
				del: (k) ->
					if k of index
						i = index[k]
						order.splice i, 1
						delete index[k]
						reIndex i, order.length - 1
				set: (k, v, ttl = @defaultTtl) =>
					return v unless @capacity > 0
					if k of index
						d = order[i = index[k]]
						d.v = v
						d.w += 1
						rePosition i
					else
						autoEvict()
						item = { k, v, r: 0, w: 1 }
						i = $.sortedIndex order, item, eff
						order.splice i, 0, item
						reIndex i, order.length - 1
					if ttl < Infinity
						$.delay ttl, =>
							@del(k)
					v
				get: (k) ->
					ret = noValue
					if k of index
						i = index[k]
						ret = order[i]
						ret.r += 1
						rePosition i
					ret.v
				clear: ->
					for k of index 
						order[index[k]] = null
					index = Object.create(null)
					order = []
	return $: Cache: $.extend EffCache, new EffCache(10000)
$.plugin
	provides: "cartesian"
, ->
	$:
		cartesian: (sets...) ->
			n = sets.length
			ret = []
			helper = (cur, i) ->
				(return ret.push cur) if ++i >= n
				for x in sets[i]
					helper (cur.concat x), i
				null
			helper [], -1
			return $(ret)
$.plugin {
	provides: "clone"
	depends: "type"
}, ->
	$.type.extend {
		unknown: clone: (s) -> null 
		string:  clone: (s) -> s + ""
		number:  clone: (n) -> n + 0.0
		array:   clone: (a) -> a.concat []
		bling:   clone: (b) -> b.concat []
		object:  clone: (o) ->
			ret = Object.create(o.__proto__)
			for own k,v of o then ret[k] = $.type.lookup(v).clone(v)
			return ret
	}
	return { $: { clone: (o) -> $.type.lookup(o).clone(o) } }
$.plugin
	provides: "compat,trimLeft,split,lastIndexOf,join,preventAll,matchesSelector,isBuffer,Map"
, ->
	$.global.Buffer or= { isBuffer: -> false }
	$.global.Map or= class Map 
		constructor: (iterable) ->
			data = Object.create null
			$.extend @, {
				size:       0
				keys:       -> Object.keys(data)
				values:     -> (v for k,v of data)
				entries:    -> ( [k,v] for k,v of data )
				has:    (k) -> k of data
				get:    (k) -> data[k]
				set: (k, v) ->
					@size += 1 unless k of data
					data[k] = v
					@
				delete: (k) ->
					@size -= 1 if k of data
					delete data[k]
					@
				clear:      ->
					data = Object.create null
					@size = 0
					@
				forEach: (cb, c) ->
					cb.call(c,k,v) for k,v of data
					@
			}
			for item in iterable ? []
				@set item...
	signs = [-1, 1]
	Math.sign = (n) -> signs[0 + (n >= 0)]
	String.prototype.trimLeft or= -> @replace(/^\s+/, "")
	String.prototype.split or= (sep) ->
		a = []; i = 0
		while (j = @indexOf sep,i) > -1
			a.push @substring(i,j)
			i = j + 1
		a
	String.prototype.lastIndexOf or= (s, c, i = -1) ->
		j = -1
		j = i while (i = s.indexOf c, i+1) > -1
		j
	Array.prototype.join or= (sep = '') ->
		n = @length
		return "" if n is 0
		s = @[n-1]
		while --n > 0
			s = @[n-1] + sep + s
		s
	if Event?
		Event.prototype.preventAll = () ->
			@preventDefault()
			@stopPropagation()
			@cancelBubble = true
	if Element?
		Element.prototype.matchesSelector = Element.prototype.webkitMatchesSelector or
			Element.prototype.mozMatchesSelector or
			Element.prototype.matchesSelector
	return { }
$.plugin {
	provides: "compress, decompress"
}, ->
	f = String.fromCharCode
	chr = (i) -> f(i+32)
	{ pow } = Math
	_compress = (input) ->
		if input in [null,undefined,""]
			return input
		dict         = {}
		dictToCreate = {}
		c            = ""
		wc           = ""
		w            = ""
		enlargeIn    = 2 
		dictSize     = 3
		numBits      = 2
		data         = []
		data_val     = 0
		data_pos     = 0
		doSomeBits = (how_many_bits, value=0) ->
			for i in [0...numBits] by 1
				data_val = (data_val << 1) | value
				if data_pos == 14
					data_pos = 0
					data.push chr data_val
					data_val = 0
				else
					data_pos++
				value = 0
			value = w.charCodeAt(0);
			doBitsAndOne(how_many_bits, value)
		
		doBitsAndOne = (how_many_bits, value=0) ->
			for i in [0...how_many_bits] by 1
				data_val = (data_val << 1) | (value&1)
				if data_pos == 14
					data_pos = 0;
					data.push(chr(data_val));
					data_val = 0;
				else
					data_pos++
				value = value >> 1
		for c in input
			unless c of dict
				dict[c] = dictSize++
				dictToCreate[c] = true;
			wc = w + c
			if wc of dict
				w = wc
			else
				if w of dictToCreate
					if w.charCodeAt(0)<256
						doSomeBits(8)
					else
						doSomeBits(16, 1)
					enlargeIn--
					if enlargeIn == 0
						enlargeIn = pow 2, numBits
						numBits++
					delete dictToCreate[w]
				else
					value = dict[w];
					doBitsAndOne(numBits, value)
				enlargeIn--
				if enlargeIn == 0
					enlargeIn = pow(2, numBits);
					numBits++;
				dict[wc] = dictSize++
				w = String c
		if w isnt ""
			if w of dictToCreate
				if w.charCodeAt(0)<256
					doSomeBits(8)
				else
					doSomeBits(16,1)
				enlargeIn--;
				if enlargeIn == 0
					enlargeIn = pow 2, numBits
					numBits++
				delete dictToCreate[w]
			else
				value = dict[w]
				doBitsAndOne(numBits, value)
			enlargeIn--
			if enlargeIn == 0
				enlargeIn = pow 2, numBits
				numBits++
		doBitsAndOne(numBits, 2)
		while true
			data_val = (data_val << 1)
			if data_pos == 14
				data.push chr data_val
				break
			else data_pos++
		return data.join('');
	_decompress = (length, resetValue, getNextValue) ->
		return "" if length is 0
		dict = []
		enlargeIn = 4
		dictSize = 4
		numBits = 3
		entry = ""
		result = []
		next = i = w = resb = c = null
		data = {val:getNextValue(0), position:resetValue, index:1}
		if isNaN(data.val) or not isFinite(data.val) or not data.val?
			return ""
		dict[0] = 0
		dict[1] = 1
		dict[2] = 2
		doBits = (bits, maxpower, power=1) ->
			while power isnt maxpower
				resb = data.val & data.position
				data.position >>= 1
				if data.position == 0
					data.position = resetValue
					data.val = getNextValue(data.index++)
				r = if resb > 0 then 1 else 0
				bits |= r * power;
				power <<= 1;
			bits
		
		bits = doBits(0,4,1)
		switch next = bits
			when 0,1
				c = f doBits(0, pow(2,8*(c+1)),1)
			when 2
				return ""
		dict[3] = c
		w = c
		result.push(c)
		while true
			if data.index > length
				return "";
			switch c = doBits(0, pow(2,numBits), 1)
				when 0,1
					dict[dictSize++] = f doBits(0, pow(2,8*(c+1)), 1)
					c = dictSize-1
					enlargeIn--
				when 2
					return result.join('');
			if enlargeIn == 0
				enlargeIn = pow(2, numBits)
				numBits++
			if dict[c]
				entry = dict[c]
			else
				if c == dictSize
					entry = w + w.charAt(0)
				else
					return "";
			result.push(entry)
			dict[dictSize++] = w + entry.charAt(0)
			enlargeIn--
			w = entry
			if enlargeIn == 0
				enlargeIn = pow(2, numBits)
				numBits++
	return {
		$:
			compress: (input) ->
				if input then return _compress(input, 15) + " ";
				else return ""
			decompress: (input) ->
				if input then return _decompress input.length, 16384, (i) -> input.charCodeAt(i) - 32
				else return ""
	}
$.plugin
	provides: 'config'
	depends: 'core'
, ->
	get = (name, def) -> switch arguments.length
		when 0 then $.extend {}, process.env
		else process.env[name] ? def
	set = (name, val) -> switch arguments.length
		when 1 then $.extend process.env, name
		when 2 then process.env[name] = val
	parse = (data) ->
		ret = {}
		$(data.toString("utf8").split "\n") \
			.filter($.isEmpty, false) \
			.filter(/^#/, false) \
			.map(-> @replace(/^\s+/,'').split '=') \
			.each (kv) -> if kv[0]?.length then ret[kv[0]] = kv[1] \
				.replace(/^["']/,'') \
				.replace(/['"]$/,'')
		ret
	watch = (name, func) ->
		prev = process.env[name]
		$.interval 1003, ->
			if (cur = process.env[name]) isnt prev
				func prev, cur
				prev = cur
	int = (name, def) -> parseInt(process.env[name] ? def, 10)
	float = (name, def) -> parseFloat(process.env[name] ? def)
	$: config: $.extend get, {get, set, parse, watch, int, float}
$.plugin
	provides: "core,eq,each,map,filterMap,tap,replaceWith,reduce,union,intersect,distinct," +
		"contains,count,coalesce,swap,shuffle,select,or,zap,clean,take,skip,first,last,slice," +
		"push,filter,matches,weave,fold,flatten,call,apply,log,toArray,clear,indexWhere"
	depends: "string,type"
, ->
	$.defineProperty $, "now",
		get: -> +new Date
	index = (i, o) ->
		i += o.length while i < 0
		Math.min i, o.length
	
	return {
		$:
			assert: (c, m="") -> if not c then throw new Error("assertion failed: #{m}")
			coalesce: (a...) -> $(a).coalesce()
			keysOf: (o, own=false) ->
				if own then $(k for own k of o)
				else $(k for k of o)
			valuesOf: (o, own=false) ->
				if own then $(v for own k,v of o)
				else $(v for k,v of o)
		eq: (i) -> $([@[index i, @]])
		each: (f) -> (f.call(t,t) for t in @); @
		map: (f) ->
			b = $()
			i = 0
			(b[i++] = f.call t,t) for t in @
			return b
		every: (f) ->
			for x in @ when not f.call x,x
				return false
			return true
		some: (f) ->
			for x in @ when f.call x,x
				return true
			return false
		filterMap: (f) ->
			b = $()
			for t in @
				v = f.call t,t
				if v?
					b.push v
			b
		tap: (f) -> f.call @, @
		replaceWith: (array) ->
			@clear()
			@push x for x in array
			@
		reduce: (f, a) ->
			if (typeof a) is 'function'
				[f, a] = [a, f]
			i = 0; n = @length
			a = @[i++] if not a?
			(a = f.call @[x], a, @[x]) for x in [i...n] by 1
			return a
		union: (other, strict = true) ->
			ret = $()
			ret.push(x) for x in @ when not ret.contains(x, strict)
			ret.push(x) for x in other when not ret.contains(x, strict)
			ret
		distinct: (strict = true) -> @union @, strict
		intersect: (other) -> $(x for x in @ when x in other) 
		contains: (item, strict = true) ->
			if strict
				return @indexOf(item) > -1
			else for t in @ when `t == item`
				return true
			false
		count: (item, strict = true) ->
			n = 0
			++n for t in @ when (item is undefined) \
				or (strict and t is item) \
				or (not strict and `t == item`)
			n
		coalesce: ->
			for i in @
				if $.type.in 'array','bling', i then i = $(i).coalesce()
				if i? then return i
			null
		swap: (i,j) ->
			i = index i, @
			j = index j, @
			if i isnt j
				[@[i],@[j]] = [@[j],@[i]]
			@
		shuffle: ->
			i = @length-1
			while i >= 0
				@swap --i, Math.floor(Math.random() * i)
			@
		select: do ->
			getter = (prop) -> ->
				if $.is("function",v = @[prop]) and prop isnt "constructor"
					return $.bound(@,v)
				else v
			selectOne = (p) ->
				switch type = $.type p
					when 'regexp' then selectMany.call @, p
					when 'string','number'
						p = String(p)
						if p is "*" then @flatten()
						else if (i = p.indexOf '.') > -1 then @select(p.substr 0,i).select(p.substr i+1)
						else @map(getter p)
					else $()
			selectMany = (a...) ->
				n = @length
				lists = Object.create(null)
				for p in a
					if $.is 'regexp', p
						for match in $.keysOf(@[0]).filter(p)
							lists[match] = @select(match)
					else lists[p] = @select(p)
				i = 0
				@map ->
					obj = Object.create(null)
					for p of lists
						key = p.split('.').pop()
						val = lists[p][i]
						unless val is undefined
							obj[key] = val
					i++
					obj
			return ->
				switch arguments.length
					when 0 then @
					when 1 then selectOne.apply @, arguments
					else selectMany.apply @, arguments
		or: (x) -> @[i] or= x for i in [0...@length]; @
		zap: (p, v) ->
			if $.is 'object', p
				@zap(k,v) for k,v of p
				return @
			i = p.lastIndexOf "."
			if i > 0
				head = p.substr 0,i
				tail = p.substr i+1
				@select(head).zap tail, v
				return @
			switch $.type(v)
				when "array","bling" then @each -> @[p] = v[++i % v.length]
				when "function" then @zap p, @select(p).map(v)
				else @each -> @[p] = v
			@
		clean: (props...) ->
			@each ->
				for prop in props
					switch $.type prop
						when 'string','number' then delete @[prop]
						when 'regexp'
							for key in Object.keys(@) when prop.test key
								delete @[key]
				null
		take: (n = 1) ->
			end = Math.min n, @length
			$( @[i] for i in [0...end] by 1 )
		skip: (n = 0) ->
			start = Math.max 0, n|0
			$( @[i] for i in [start...@length] by 1 )
		first: (n = 1) -> if n is 1 then @[0] else @take(n)
		last: (n = 1) -> if n is 1 then @[@length - 1] else @skip(@length - n)
		slice: (start=0, end=@length) ->
			start = index start, @
			end = index end, @
			$( @[i] for i in [start...end] )
		extend: (b) -> @.push(i) for i in b; @
		push: (b) -> Array.prototype.push.call(@, b); @
		unshift: (b) -> Array.prototype.unshift.call(@, b); @
		filter: (f, limit, positive) ->
			if $.is "bool", limit
				[positive, limit] = [limit, positive]
			if $.is "number", positive
				[limit, positive] = [positive, limit]
			limit ?= @length
			positive ?= true
			g = switch
				when $.is "object", f then (x) -> $.matches f,x
				when $.is "string", f then (x) -> x?.matchesSelector?(f) ? false
				when $.is "regexp", f then (x) -> f.test(x)
				when $.is "function", f then f
				when $.type.in "bool","number","null","undefined", f then (x) -> f is x
				else throw new Error "unsupported argument to filter: #{$.type f}"
			a = $()
			for it in @
				if (!! g.call it,it) is positive
					if --limit < 0
						break
					a.push it
			a
		matches: (expr) ->
			switch
				when $.is "string", expr then @select('matchesSelector').call(expr)
				when $.is "regexp", expr then @map (x) -> expr.test x
				else throw new Error "unsupported argument to matches: #{$.type expr}"
		weave: (b) ->
			c = $()
			for i in [@length-1..0] by -1
				c[(i*2)+1] = @[i]
			for i in [0...b.length] by 1
				c[i*2] = b[i]
			c
		fold: (f) ->
			n = @length
			b = $( f.call @, @[i], @[i+1] for i in [0...n-1] by 2 )
			if (n%2) is 1
				b.push( f.call @, @[n-1], undefined )
			b
		flatten: ->
			b = $()
			for item, i in @
				if $.type.in 'array','bling','arguments','nodelist', item
					for j in item then b.push(j)
				else b.push(item)
			b
		call: -> @apply(null, arguments)
		apply: (context, args) ->
			@filterMap ->
				if $.is "function", @ then @apply(context, args)
				else null
		log: (label) ->
			if label
				$.log(label, @toString(), @length + " items")
			else
				$.log(@toString(), @length + " items")
			@
		toArray: ->
			@__proto__ = Array.prototype
			@ 
		clear: -> @splice 0, @length
		indexWhere: (f) ->
			for x,i in @
				return i if (f.call x,x)
			return -1
	}
$.plugin
	provides: "css,CSS"
	depends: "type"
, ->
	flatten = (o, prefix, into) ->
		unless prefix of into
			into[prefix] = []
		for k,v of o
			switch typeof v
				when "string","number"
					nk = k.replace(/([a-z]+)([A-Z]+)/g, "$1-$2").toLowerCase()
					into[prefix].push "#{nk}: #{v};"
				when "object"
					nk = if prefix then (prefix + k) else k
					flatten(v, nk, into)
				else throw new Error("unexpected type in css: #{typeof v}")
		return into
	trim = (str) -> str.replace(/^\s+/, '').replace(/\s+$/, '')
	stripComments = (str) ->
		while (i = str.indexOf "/*") > -1
			if (j = str.indexOf "*/", i) is -1
				break 
			str = str.substring(0,i) + str.substring(j+2)
		str
	parse = (str, into) ->
		if m = str.match /([^{]+){/
			selector = trim m[1]
			rest = str.substring m[0].length
			into[selector] or= {}
			if m = rest.match /([^}]+)}/
				body = m[1].split ';'
				rest = rest.substring m[0].length
				for rule in body
					colon = rule.indexOf ':'
					continue unless key = rule.substring(0,colon)
					key = trim key
					value = trim rule.substring(colon+1)
					into[selector][key] = value
			if rest.length > 0
				return parse(rest, into)
		return into
	specialOps = '>+~'
	compact = (obj) ->
		ret = {}
		for selector, rules of obj
			for op in specialOps
				selector = selector.replace op, " #{op} "
			parts = selector.split(/\s+/)
			switch parts.length
				when 0 then continue
				when 1 then $.extend (ret[selector] or= {}), rules
				else
					cur = ret
					first = true
					for part in parts
						unless first then part = " " + part
						cur = cur[part] or= {}
						first = false
					$.extend cur, rules
		phaseTwo = (cur) ->
			modified = false
			for key, val of cur
				if $.is 'object', val
					subkeys = Object.keys(val)
					switch subkeys.length
						when 0
							delete cur[key]
						else
							if subkeys.length is 1 and $.is 'object', val[subkeys[0]]
								cur[key + subkeys[0]] = val[subkeys[0]] 
								delete cur[key] 
								phaseTwo cur 
					phaseTwo val
			cur
		return phaseTwo ret
	return {
		$:
			CSS:
				parse: (str, packed=false) ->
					
					
					
					
					
					
					
					ret = parse stripComments(str), {}
					return if packed then compact ret else ret
				stringify: (obj) ->
					return ("#{x} { #{y.join ' '} }" for x,y of flatten(obj, "", {}) when y.length > 0).join ' '
	}
$.plugin
	provides: 'date,midnight,stamp,unstamp,dateFormat,dateParse'
	depends: 'type'
, ->
	[ms,s,m,h,d] = [1,1000,1000*60,1000*60*60,1000*60*60*24]
	units = {
		ms, s, m, h, d,
		sec: s
		second: s
		seconds: s
		min: m
		minute: m
		minutes: m
		hr: h
		hour: h
		hours: h
		day: d
		days: d
	}
	shortDays = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
	longDays = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
	formats =
		yyyy: Date.prototype.getUTCFullYear
		YY: fYY = -> String(@getUTCFullYear()).substr(2)
		yy: fYY
		mm: -> @getUTCMonth() + 1
		dd: Date.prototype.getUTCDate
		dw: Date.prototype.getUTCDay 
		dW: -> shortDays[parseInt(@getUTCDay(), 10) - 1]
		DW: -> longDays[parseInt(@getUTCDay(), 10) - 1]
		HH: Date.prototype.getUTCHours
		MM: Date.prototype.getUTCMinutes
		SS: Date.prototype.getUTCSeconds
		MS: Date.prototype.getUTCMilliseconds
		_MS: -> $.padLeft Date.prototype.getUTCMilliseconds.apply(@), 3, "0"
	format_keys = Object.keys(formats).sort().reverse()
	parsers =
		YYYY: pYYYY = Date.prototype.setUTCFullYear
		yyyy: pYYYY
		YY: pYY = (x) -> @setUTCFullYear (if x > 50 then 1900 else 2000) + x
		yy: pYY
		mm: (x) -> @setUTCMonth(x - 1)
		dd: Date.prototype.setUTCDate
		HH: Date.prototype.setUTCHours
		MM: Date.prototype.setUTCMinutes
		SS: Date.prototype.setUTCSeconds
		_MS: (s) -> @setUTCMilliseconds parseInt s, 10
		MS: Date.prototype.setUTCMilliseconds
	parser_keys = Object.keys(parsers).sort().reverse()
	floor = Math.floor
	$.type.register "date",
		is: (o) -> $.isType Date, o
		array: (o) -> [o]
		string: (o, fmt, unit) -> $.date.format o, fmt, unit
		number: (o, unit) -> $.date.stamp o, unit
	$.type.extend 'string', date: (s, fmt = $.date.defaultFormat) -> new Date $.date.parse s, fmt, "ms"
	$.type.extend 'number', date: (n, unit = $.date.defaultUnit) -> $.date.unstamp n, unit
	adder = (key) ->
		(stamp, delta, stamp_unit = $.date.defaultUnit) ->
			date = $.date.unstamp(stamp, stamp_unit)
			parsers[key].call date, (formats[key].call date) + delta
			$.date.stamp date, stamp_unit
	$:
		date:
			defaultUnit: "s"
			defaultFormat: "yyyy-mm-dd HH:MM:SS"
			stamp: (date = new Date, unit = $.date.defaultUnit) ->
				floor (date / units[unit])
			unstamp: (stamp, unit = $.date.defaultUnit) ->
				new Date floor stamp * units[unit]
			convert: (stamp, from = $.date.defaultUnit, to = $.date.defaultUnit) ->
				if $.is "date", stamp then stamp = $.date.stamp(stamp, from)
				(floor stamp * units[from] / units[to])
			midnight: (stamp, unit = $.date.defaultUnit) ->
				$.date.convert ($.date.convert stamp, unit, "d"), "d", unit
			format: (stamp, fmt = $.date.defaultFormat, unit = $.date.defaultUnit) ->
				if $.is "date", stamp then stamp = $.date.stamp(stamp, unit)
				date = $.date.unstamp stamp, unit
				for k in format_keys
					fmt = fmt.replace k, ($.padLeft ""+formats[k].call(date), k.length, "0")
				fmt
			parse: (dateString, fmt = $.date.defaultFormat, to = $.date.defaultUnit) ->
				date = new Date(0)
				i = 0
				while i < fmt.length
					for k in parser_keys
						if fmt.indexOf(k, i) is i
							try
								parsers[k].call date,
									parseInt dateString[i...i+k.length], 10
							catch err
								throw new Error("Invalid date ('#{dateString}') given format mask: #{fmt} (failed at position #{i})")
							i += k.length - 1
							break
					i += 1
				$.date.stamp date, to
			addMilliseconds: adder("MS")
			addSeconds:      adder("SS")
			addMinutes:      adder("MM")
			addHours:        adder("HH")
			addDays:         adder("dd")
			addMonths:       adder("mm")
			addYears:        adder("yyyy")
			range: (from, to, interval=1, interval_unit="dd", stamp_unit = $.date.defaultUnit) ->
				add = adder(interval_unit)
				ret = [from]
				while (cur = ret[ret.length-1]) < to
					ret.push add(cur, interval, stamp_unit)
				ret
	midnight: (unit = $.date.defaultUnit) -> @map(-> $.date.midnight @, unit)
	unstamp: (unit = $.date.defaultUnit) -> @map(-> $.date.unstamp @, unit)
	stamp: (unit = $.date.defaultUnit) -> @map(-> $.date.stamp @, unit)
	dateFormat: (fmt = $.date.defaultFormat, unit = $.date.defaultUnit) -> @map(-> $.date.format @, fmt, unit)
	dateParse: (fmt = $.date.defaultFormat, unit = $.date.defaultUnit) -> @map(-> $.date.parse @, fmt, unit)
$.plugin
	provides: "debug, debugStack",
	depends: "core"
, ->
	explodeStack = (stack, node_modules) ->
		nl = /(?:\r\n|\r|\n)/
		fs = null
		try fs = require 'fs'
		catch err then return stack 
		lines = $(String(stack).split nl).filter(/^$/, false)
		unless node_modules
			lines = lines.filter(/node_modules/, false)
		message = lines.first()
		lines = lines.skip 1
		lines_cache = Object.create null
		files = lines.map (s) ->
			unless s? then return null
			f = s.replace(/^\s*at\s+/g,'') \
				.replace(/.*\(([^:]+:\d+:\d+)\)$/, "$1")
			try
				[f,ln_num,col] = f.split(/:/)
				f_lines = lines_cache[f] ?= String(fs.readFileSync f).split nl
				unless f_lines?
					return null
				before = ""
				if ln_num > 1
					before = f_lines[ln_num-2]
					if before.length > 80
						before = "..8<.. " + before.substr(col-25,50) + " ..>8.."
				if ln_num >= f_lines.length
					return null
				line = f_lines[ln_num-1]
				unless line?
					return null
				if line.length > 80
					line = "..8<.." + line.substr(col-25,50) + "..>8.."
					col = 31
				tabs = line.replace(/[^\t]/g,'').length
				spacer = $.repeat('\t', tabs) + $.repeat(' ', (col-1)-tabs)
				return """  #{ln_num-1} #{before}\n  #{ln_num} #{line}\n  #{ln_num} #{spacer}^"""
			catch err
				return null
		return message + "\n" + $.weave(files, lines).filter(null, false).join "\n"
	protoChain = (obj, arr) ->
		return arr unless obj and obj.constructor
		return protoChain obj.__proto__, arr.push obj.constructor
	return $: {
		debugStack: (error, node_modules=false) ->
			stack = switch
				when $.is 'error', error then String(error.stack)
				when $.is 'string', error then error
				else String(error)
			explodeStack stack, node_modules
		protoChain: (o) -> protoChain(o.__proto__, $())
	}
$.plugin
	provides: "delay,immediate,interval"
	depends: "is,select,extend,bound,core"
, ->
	$:
		delay: do ->
			timeoutQueue = $.extend [], do ->
				next = (a) -> -> (do a.shift()) if a.length; null
				add: (f, n) ->
					$.extend f,
						order: n + $.now
						timeout: setTimeout next(@), n
					for i in [0..@length] by 1
						if i is @length or @[i].order > f.order
							@splice i,0,f
							break
					@
				cancel: (f) ->
					if (i = @indexOf f) > -1
						@splice i, 1
						clearTimeout f.timeout
					@
			(n, f) -> switch
				when $.is 'object', n
					b = $($.delay(k,v) for k,v of n)
					{
						cancel: -> b.select('cancel').call()
						unref: -> b.select('unref').call()
						ref: -> b.select('ref').call()
					}
				when $.is "function", f
					timeoutQueue.add f, parseInt(n,10)
					{
						cancel: -> timeoutQueue.cancel(f)
						unref: (f) -> f.timeout?.unref()
						ref: (f) -> f.timeout?.ref()
					}
				else throw new Error "Bad arguments to $.delay (expected: int,function given: #{$.type n},#{$.type f})"
		immediate: switch
			when 'setImmediate' of $.global then $.global.setImmediate
			when process?.nextTick? then process.nextTick
			else (f) -> setTimeout(f, 0)
		interval: (n, f) ->
			paused = false
			ret = $.delay n, g = ->
				unless paused then do f
				$.delay n, g
			$.extend ret,
				pause: (p=true) -> paused = p
				resume: (p=true) -> paused = not p
	delay: (n, f) ->
		$.delay n, $.bound @, f
		@
$.plugin
	depends: "inherit,reduce"
	provides: "diff,stringDistance,stringDiff"
, ->
	lev_memo = Object.create null
	min = Math.min
	lev = (s,i,n,t,j,m,dw,iw,sw) ->
		return lev_memo[[s,i,n,t,j,m,dw,iw,sw]] ?= lev_memo[[t,j,m,s,i,n,dw,iw,sw]] ?= do -> switch
			when m <= 0 then n
			when n <= 0 then m
			else min(
				dw + lev(s,i+1,n-1, t,j,m,dw,iw,sw),
				iw + lev(s,i,n, t,j+1,m-1,dw,iw,sw),
				(sw * (s[i] isnt t[j])) + lev(s,i+1,n-1, t,j+1,m-1,dw,iw,sw)
			)
	collapse = (ops) -> 
		$.inherit {
			toHTML: ->
				@reduce(((a,x) ->
					a += switch x.op
						when 'ins' then "<ins>#{x.v}</ins>"
						when 'del' then "<del>#{x.v}</del>"
						when 'sub' then "<del>#{x.v}</del><ins>#{x.w}</ins>"
						when 'sav' then x.v
				), "")
		}, ops.reduce(((a,x) ->
			if x.op is 'sub' and x.v is x.w 
				x.op = 'sav'
				delete x.w
			unless a.length
				a.push x
			else
				if (last = a.last()).op is x.op
					last.v += x.v
					if last.op is 'sub'
						last.w += x.w
				else
					a.push x
			return a
		), $())
	diff_memo = Object.create null
	del = (c) -> {op:'del',v:c}
	ins = (c) -> {op:'ins',v:c}
	sub = (c,d) -> {op:'sub',v:c,w:d}
	diff = (s,i,n,t,j,m,dw,iw,sw) ->
		return diff_memo[[s,i,n,t,j,m,dw,iw,sw]] ?= collapse do -> switch
			when m <= 0 then (del c) for c in s.substr i,n
			when n <= 0 then (ins c) for c in t.substr j,m
			else
				sw *= (s[i] isnt t[j])
				args =
					del: [s+0,i+1,n-1,t+0,j+0,m+0,  1.00,1.50,1.50]
					ins: [s+0,i+0,n+0,t+0,j+1,m-1,  1.50,1.00,1.50]
					sub: [s+0,i+1,n-1,t+0,j+1,m-1,  1.00,1.00,1.00]
				costs =
					del: dw + lev args.del...
					ins: iw + lev args.ins...
					sub: sw + lev args.sub...
				switch min costs.del, costs.ins, costs.sub
					when costs.del then $(del s[i]).concat diff args.del...
					when costs.ins then $(ins t[j]).concat diff args.ins...
					when costs.sub then $(sub s[i],t[j]).concat diff args.sub...
	$:
		stringDistance: (s, t) -> lev s,0,s.length, t,0,t.length,1,1,1
		stringDiff: (s, t) -> diff s,0,s.length, t,0,t.length,1,1,1.5
if $.global.document?
	$.plugin
		provides: "dom,HTML,html,append,appendText,appendTo,prepend,prependTo," +
			"before,after,wrap,unwrap,replace,attr,data,addClass,removeClass,toggleClass," +
			"hasClass,text,val,css,defaultCss,rect,width,height,top,left,bottom,right," +
			"position,scrollToCenter,child,parents,next,prev,remove,find,querySelectorAll," +
			"clone,toFragment"
		depends: "function,type,string"
	, ->
		bNodelistsAreSpecial = false
		$.type.register "nodelist",
			is:			(o) -> o? and $.isType "NodeList", o
			hash:		(o) -> $($.hash(i) for i in o).sum()
			array:	do ->
				try 
					document.querySelectorAll("xxx").__proto__ = {}
					return $.identity
				catch err 
					bNodelistsAreSpecial = true
					return (o) -> (node for node in o)
			string: (o) -> "{Nodelist:["+$(o).select('nodeName').join(",")+"]}"
			node:		(o) -> $(o).toFragment()
		$.type.register "node",
			is:  (o) -> o?.nodeType > 0
			hash:		(o) -> $.checksum(o.nodeName) + $.hash(o.attributes) + $.checksum(o.innerHTML)
			string: (o) -> o.toString()
			node:		$.identity
		$.type.register "fragment",
			is:  (o) -> o?.nodeType is 11
			hash:		(o) -> $($.hash(x) for x in o.childNodes).sum()
			string: (o) -> o.toString()
			node:		$.identity
		$.type.register "html",
			is:  (o) -> typeof o is "string" and (s=o.trimLeft())[0] == "<" and s[s.length-1] == ">"
			node:		(h) ->
				(node = document.createElement('div')).innerHTML = h
				if (n = (childNodes = node.childNodes).length) is 1
					return node.removeChild(childNodes[0])
				df = document.createDocumentFragment()
				df.appendChild(node.removeChild(childNodes[0])) for i in [0...n] by 1
				df
			array:	(o) -> $.type.lookup(h = $.HTML.parse o).array h
			string: (o) -> "'#{o}'"
			repr:		(o) -> '"' + o + '"'
		$.type.extend
			unknown:	{ node: -> null }
			bling:		{ node: (o) -> o.toFragment() }
			node:			{ html: (n) ->
				d = document.createElement "div"
				d.appendChild (n = n.cloneNode true)
				ret = d.innerHTML
				d.removeChild n 
				ret
			}
			string:
				node:  (o) -> $(o).toFragment()
				array: do ->
					if bNodelistsAreSpecial
						(o) -> $.type.lookup(nl = document.querySelectorAll o).array(nl)
					else
						(o) -> document.querySelectorAll o
			function: { node: (o) -> $(o.toString()).toFragment() }
		toFrag  = (a) ->
			unless a.parentNode
				document.createDocumentFragment().appendChild a
			a
		before  = (a,b) -> toFrag(a).parentNode.insertBefore b, a
		after   = (a,b) -> toFrag(a).parentNode.insertBefore b, a.nextSibling
		toNode  = (x) -> $.type.lookup(x).node x
		escaper = false
		parser  = false
		$.computeCSSProperty = (k) -> -> $.global.getComputedStyle(@, null).getPropertyValue k
		getOrSetRect = (p) -> (x) -> if x? then @css(p, x) else @rect().select p
		selectChain = (prop) -> -> @map (p) -> $( p while p = p[prop] )
		return {
			$:
				HTML:
					parse: (h) -> $.type.lookup(h).node h
					stringify: (n) -> $.type.lookup(n).html n
					escape: (h) ->
						escaper or= $("<div>&nbsp;</div>").child 0
						ret = escaper.zap('data', h).select("parentNode.innerHTML").first()
						escaper.zap('data', '')
						ret
			html: (h) ->
				return switch $.type h
					when "undefined","null" then @select 'innerHTML'
					when "string","html" then @zap 'innerHTML', h
					when "bling" then @html h.toFragment()
					when "node"
						@each -> 
							@replaceChild @childNodes[0], h
							while @childNodes.length > 1
								@removeChild @childNodes[1]
			append: (x) -> 
				x = toNode(x) 
				return unless x?
				@each (n) -> n?.appendChild? x.cloneNode true
			appendText: (text) ->
				x = document.createTextNode(text)
				return unless x?
				@each (n) -> n?.appendChild? x.cloneNode true
			appendTo: (x) -> 
				clones = @map( -> @cloneNode true)
				i = 0
				$(x).each -> @appendChild clones[i++]
				clones
			prepend: (x) -> 
				if x?
					x = toNode x
					@take(1).each -> switch
						when @childNodes.length > 0 then before @childNodes[0], x
						else @appendChild x
					@skip(1).each -> switch
						when @childNodes.length then before @childNodes[0], x.cloneNode true
						else @appendChild x.cloneNode true
				@
			prependTo: (x) -> 
				if x?
					$(x).prepend(@)
				@
			before: (x) -> 
				if x?
					x = toNode x
					@take(1).each -> before @, x
					@skip(1).each -> before @, x.cloneNode true
				@
			after: (x) -> 
				if x?
					x = toNode x
					@take(1).each -> after @, x
					@skip(1).each -> after @, x.cloneNode true
				@
			wrap: (parent) -> 
				parent = toNode parent
				if $.is "fragment", parent
					throw new Error("cannot call .wrap() with a fragment as the parent")
				@each (child) ->
					if ($.is "fragment", child) or not child.parentNode
						return parent.appendChild child
					grandpa = child.parentNode
					marker = document.createElement "dummy"
					parent.appendChild grandpa.replaceChild marker, child
					grandpa.replaceChild parent, marker
			unwrap: -> 
				@each ->
					if @parentNode and @parentNode.parentNode
						@parentNode.parentNode.replaceChild(@, @parentNode)
					else if @parentNode
						@parentNode.removeChild(@)
			replace: (n) -> 
				if $.is 'regexp', n
					r = arguments[1]
					return @map (s) -> s.replace(n, r)
				n = toNode n
				clones = @map(-> n.cloneNode true)
				for i in [0...clones.length] by 1
					@[i].parentNode?.replaceChild clones[i], @[i]
				clones
			attr: (a,v) -> 
				if $.is 'object', a
					@attr(k,v) for k,v of a
				else switch v
					when undefined
						return @select("getAttribute").call(a, v)
					when null
						@select("removeAttribute").call(a, v)
					else
						@select("setAttribute").call(a, v)
				@
			data: (k, v) -> @attr "data-#{$.dashize(k)}", v
			addClass: (x) -> 
				notempty = (y) -> y isnt ""
				@removeClass(x).each ->
					c = @className.split(" ").filter notempty
					c.push x
					@className = c.join " "
			removeClass: (x) -> 
				notx = (y) -> y isnt x
				@each ->
					@className = @className.split(" ").filter(notx).join(" ")
					if @className.length is 0
						@removeAttribute('class')
			toggleClass: (x) -> 
				notx = (y) -> y isnt x
				@each ->
					cls = @className.split(" ")
					filter = $.not $.isEmpty
					if (cls.indexOf x) > -1
						filter = $.and notx, filter
					else
						cls.push x
					@className = cls.filter(filter).join(" ")
					if @className.length is 0
						@removeAttribute 'class'
			hasClass: (x) -> 
				@select('className.split').call(" ").select('indexOf').call(x).map (x) -> x > -1
			text: (t) -> 
				return @zap('textContent', t) if t?
				return @select('textContent')
			val: (v) -> 
				return @zap('value', v) if v?
				return @select('value')
			css: (key,v) ->
				if v? or $.is('object', key)
					setters = @select 'style.setProperty'
					if $.is "object", key then setters.call k, v, "" for k,v of key
					else if $.is "array", v
						for i in [0...n = Math.max v.length, nn = setters.length] by 1
							setters[i%nn](key, v[i%n], "")
					else if $.is "function", v
						values = @select("style.#{key}") \
							.weave(@map $.computeCSSProperty key) \
							.fold($.coalesce) \
							.weave(setters) \
							.fold (setter, value) -> setter(key, v.call value, value)
					else setters.call key, v, ""
					return @
				else @select("style.#{key}") \
					.weave(@map $.computeCSSProperty key) \
					.fold($.coalesce)
			defaultCss: (k, v) ->
				sel = @selector
				style = ""
				if $.is "string", k
					if $.is "string", v
						style += "#{sel} { #{k}: #{v} } "
					else throw Error("defaultCss requires a value with a string key")
				else if $.is "object", k
					style += "#{sel} { " +
						"#{i}: #{k[i]}; " for i of k +
					"} "
				$("<style></style>").text(style).appendTo("head")
				@
			rect: -> @map (item) -> switch item
				when window then {
					width: window.innerWidth
					height: window.innerHeight
					top: 0
					left: 0
					right: window.innerWidth
					bottom: window.innerHeight
				}
				else item.getBoundingClientRect()
			width: getOrSetRect("width")
			height: getOrSetRect("height")
			top: getOrSetRect("top")
			left: getOrSetRect("left")
			bottom: getOrSetRect("bottom")
			right: getOrSetRect("right")
			position: (left, top) ->
				switch
					when not left? then @rect()
					when not top? then @css("left", $.px(left))
					else @css({top: $.px(top), left: $.px(left)})
			scrollToCenter: ->
				document.body.scrollTop = @[0].offsetTop - ($.global.innerHeight / 2)
				@
			child: (n) -> @select('childNodes').map -> @[ if n < 0 then (n+@length) else n ]
			parents: selectChain('parentNode')
			prev: selectChain('previousSibling')
			next: selectChain('nextSibling')
			remove: -> @each -> @parentNode?.removeChild(@)
			find: (css, limit = 0) ->
				@filter("*")
					.map(
						switch limit
							when 0 then (-> @querySelectorAll css)
							when 1 then (-> $ @querySelector css)
							else (-> $(@querySelectorAll css).take(limit) )
					)
					.flatten()
			querySelectorAll: (expr) ->
				@filter("*")
				.reduce (a, i) ->
					a.extend i.querySelectorAll expr
				, $()
			clone: (deep=true, count=1) ->
				c = (n) -> if $.is "node", n then (n.cloneNode deep)
				@map -> switch count
					when 1 then c @
					else (c(@) for _ in [0...count] by 1)
			toFragment: ->
				if @length > 1
					df = document.createDocumentFragment()
					(@map toNode).map (node) -> df.appendChild(node)
					return df
				return toNode @[0]
		}
$.plugin
	provides: "EventEmitter"
	depends: "type,hook"
, ->
	$: EventEmitter: $.init.append (obj) ->
		if obj in [$.global, null, undefined]
			if this in [$.global, $]
				obj = {}
			else obj = this
		listeners = Object.create null
		list = (e) -> (listeners[e] or= [])
		return $.inherit {
			emit:               (e, a...) -> (f.apply(@, a) for f in list(e)); @
			on: add = (e, f) ->
				('string' is typeof e) and \
					list(e).push(f)
				('object' is typeof e) and \
					@addListener(k,v) for k,v of e
				@
			addListener: add
			removeListener:     (e, f) -> (l.splice i, 1) if (i = (l = list e).indexOf f) > -1
			removeAllListeners: (e) -> listeners[e] = []
			setMaxListeners:        -> 
			listeners:          (e) -> list(e).slice 0
		}, obj
$.plugin
	depends: "dom,function,core"
	provides: "event,bind,unbind,trigger,delegate,undelegate,click,ready"
, ->
	EVENTSEP_RE = /,* +/
	events = ['mousemove','mousedown','mouseup','mouseover','mouseout','blur','focus',
		'load','unload','reset','submit','keyup','keydown','keypress','change',
		'abort','cut','copy','paste','selection','drag','drop','orientationchange',
		'touchstart','touchmove','touchend','touchcancel',
		'gesturestart','gestureend','gesturecancel',
		'hashchange'
	]
	binder = (e) -> (f) ->
		if $.is "function", f then @bind e, f
		else @trigger e, f
	_get = (self, keys...) ->
		return if keys.length is 0 then self
		else _get (self[keys[0]] or= Object.create null), keys.slice(1)...
	triggerReady = $.once ->
		$(document).trigger("ready").unbind("ready")
		document.removeEventListener?("DOMContentLoaded", triggerReady, false)
		$.global.removeEventListener?("load", triggerReady, false)
	document.addEventListener?("DOMContentLoaded", triggerReady, false)
	$.global.addEventListener?("load", triggerReady, false)
	_b = (funcName) -> (e, f) ->
		c = (e or "").split EVENTSEP_RE
		@each -> (@[funcName] i, f, true) for i in c
	ret = {
		bind: _b "addEventListener"
		unbind: _b "removeEventListener"
		trigger: (evt, args = {}) ->
			args = $.extend
				bubbles: true
				cancelable: true
			, args
			for evt_i in (evt or "").split(EVENTSEP_RE)
				switch evt_i
					when "click", "mousemove", "mousedown", "mouseup", "mouseover", "mouseout" 
						e = document.createEvent "MouseEvents"
						args = $.extend
							detail: 1,
							screenX: 0,
							screenY: 0,
							clientX: 0,
							clientY: 0,
							ctrlKey: false,
							altKey: false,
							shiftKey: false,
							metaKey: false,
							button: 0,
							relatedTarget: null
						, args
						e.initMouseEvent evt_i, args.bubbles, args.cancelable, $.global, args.detail,
							args.screenX, args.screenY, args.clientX, args.clientY,
							args.ctrlKey, args.altKey, args.shiftKey, args.metaKey,
							args.button, args.relatedTarget
					when "blur", "focus", "reset", "submit", "abort", "change", "load", "unload" 
						e = document.createEvent "UIEvents"
						e.initUIEvent evt_i, args.bubbles, args.cancelable, $.global, 1
					when "touchstart", "touchmove", "touchend", "touchcancel" 
						e = document.createEvent "TouchEvents"
						args = $.extend
							detail: 1,
							screenX: 0,
							screenY: 0,
							clientX: 0,
							clientY: 0,
							ctrlKey: false,
							altKey: false,
							shiftKey: false,
							metaKey: false,
							touches: [],
							targetTouches: [],
							changedTouches: [],
							scale: 1.0,
							rotation: 0.0
						, args
						e.initTouchEvent evt_i, args.bubbles, args.cancelable, $.global, args.detail,
							args.screenX, args.screenY, args.clientX, args.clientY,
							args.ctrlKey, args.altKey, args.shiftKey, args.metaKey,
							args.touches, args.targetTouches, args.changedTouches, args.scale, args.rotation
					when "gesturestart", "gestureend", "gesturecancel" 
						e = document.createEvent "GestureEvents"
						args = $.extend {
							detail: 1,
							screenX: 0,
							screenY: 0,
							clientX: 0,
							clientY: 0,
							ctrlKey: false,
							altKey: false,
							shiftKey: false,
							metaKey: false,
							target: null,
							scale: 1.0,
							rotation: 0.0
						}, args
						e.initGestureEvent evt_i, args.bubbles, args.cancelable, $.global,
							args.detail, args.screenX, args.screenY, args.clientX, args.clientY,
							args.ctrlKey, args.altKey, args.shiftKey, args.metaKey,
							args.target, args.scale, args.rotation
					when  "keydown", "keypress", "keyup"
						e = document.createEvent "KeyboardEvents"
						args = $.extend {
							view: null,
							ctrlKey: false,
							altKey: false,
							shiftKey: false,
							metaKey: false,
							keyCode: 0,
							charCode: 0
						}, args
						e.initKeyboardEvent evt_i, args.bubbles, args.cancelable, $.global,
							args.ctrlKey, args.altKey, args.shiftKey, args.metaKey,
							args.keyCode, args.charCode
					else
						e = document.createEvent "Events"
						e.initEvent evt_i, args.bubbles, args.cancelable
						e = $.extend e, args
				continue unless e
				@each ->
					try @dispatchEvent e
					catch err then $.log "dispatchEvent error:", err
			@
		delegate: (selector, e, f) ->
			h = (evt) -> 
				if t = $(evt.target).parents()[0]?.unshift(evt.target).filter(selector)[0]
					f.call (evt.target = t), evt
			for node in @bind(e, h) 
				_get(node,'__delegates__',selector,e)[f] = h 
			@
		undelegate: (selector, e, f) ->
			for node in @
				h = _get(node,'__delegates__',selector,e) 
				if h and h[f]
					@unbind e, h[f] 
					delete h[f] 
		click: (f = {}) ->
			if @css("cursor") in ["auto",""]
				@css "cursor", "pointer"
			if $.is "function", f then @bind 'click', f
			else @trigger 'click', f
			@
		ready: (f) ->
			return (f.call @) if triggerReady.exhausted
			@bind "ready", f
	}
	events.forEach (x) -> ret[x] = binder x
	return ret
$.plugin
	provides: "function,identity,compose,once,cycle,bound,partial"
	depends: "extend,is,defineProperty,map"
, ->
	$:
		identity: (o) -> o
		not: (f) -> -> not f.apply @, arguments
		compose: (f,g) -> (x) -> f.call(y, (y = g.call(x,x)))
		and: (f,g) -> (x) -> g.call(@,x) and f.call(@,x)
		once: (f, n=1) ->
			$.defineProperty (-> (f.apply @,arguments) if n-- > 0),
				"exhausted",
					get: -> n <= 0
		cycle: (f...) ->
			i = -1
			-> f[i = ++i % f.length].apply @, arguments
		bound: (t, f, args = []) ->
			return $.identity unless f?
			if $.is "function", f.bind
				args.splice 0, 0, t
				r = f.bind.apply f, args
			else
				r = (a...) -> f.apply t, (if args.length then args else a)
			$.extend r, { toString: -> "bound-method of #{t}.#{f.name}" }
		partial: (f, a...) -> (b...) -> f a..., b...
	partial: (a...) -> @map (f) -> $.partial f, a...
$.plugin ->
	Object.assign (do -> yield).constructor.prototype, {
		toArray: -> a = []; a.push(x) for x from this; a
		skip: (n) -> @next() while n-- > 0; @
		limit: (n) ->
			while n-- > 0
				return if (next = @next()).done
				yield next.value
			null
		map: (f) ->
			yield f(x) for x from this
			null
		filter: (f, v=true) ->
			yield x for x from this when f(x) is v
			null
		select: (key) ->
			key = key.split '.'
			yield select(x, key) for x from this
			null
	}
	select = (o, k) ->
		o = o?[x] for x in k
		o
	return { }
$.plugin
	provides: "hash"
	depends: "type"
, ->
	maxHash = 0xFFFFFFFF
	array_hash = (d) -> (o) -> d + $($.hash(x) for x in o).reduce(((a,x) -> ((a*a)+(x|0))%maxHash), 1)
	$.type.extend
		unknown:   { hash: (o) -> $.checksum $.toString o }
		object:    { hash: (o) -> 1970931729 + $($.hash(k) + $.hash(v) for k,v of o).sum() }
		array:     { hash: array_hash(1816922041) }
		arguments: { hash: array_hash(298517431) }
		bling:     { hash: array_hash(92078573) }
		bool:      { hash: (o) -> parseInt(1 if o) }
		regexp:    { hash: (o) -> 148243084 + $.checksum $.toString o }
	return {
		$: { hash: (x) -> $.type.lookup(x).hash(x) }
		hash: -> $.hash @
	}
$.plugin ->
	$:
		histogram: (data, bucket_width=1, output_width=60) ->
			buckets = $()
			len = 0
			min = Infinity
			mean = 0
			max = 0
			total = 0
			for x in data
				min = Math.min x, min
				max = Math.max x, max
				total += x
				i = Math.floor( x / bucket_width )
				if i of buckets
					buckets[i] += 1
				else
					buckets[i] = 1
				len = Math.max(len, i+1)
			buckets.length = len
			mean = total / data.length
			m = buckets.max()
			buckets = buckets.or(0)
				.scale(1/m)
				.scale(output_width)
			sum = buckets.sum()
			ret = ""
			pct_sum = 0
			for n in [0...len] by 1
				end = (n+1) * bucket_width
				pct = (buckets[n]*100/sum)
				pct_sum += pct
				if pct_sum > 0
					ret += $.padLeft(pct_sum.toFixed(2)+"%",7) +
						$.padRight(" < #{end.toFixed(2)}", 10) +
						": " + $.repeat("#", buckets[n]) + "\n"
			ret + "N: #{data.length} Min: #{min.toFixed(2)} Max: #{max.toFixed(2)} Mean: #{mean.toFixed(2)}"
	histogram: -> $.histogram @
$.plugin
	provides: "hook"
	depends: "type"
, ->
	#
	hook = ->
		chain = []
		return $.extend ((args) ->
			for func in chain
				args = func.call @, args
			args
		), {
			prepend: (o) -> chain.unshift o; o
			append: (o) -> chain.push o; o
		}
	$.init = hook()
	return $: { hook }
$.plugin
	depends: "dom"
	provides: "http"
, ->
	formencode = (obj) -> 
		return if $.is 'object', obj
			o = JSON.parse JSON.stringify obj 
			("#{i}=#{escape o[i]}" for i of o).join "&"
		else obj
	$.type.register "http",
		is: (o) -> $.isType 'XMLHttpRequest', o
		array: (o) -> [o]
	return {
		$:
			http: (url, opts = {}) ->
				xhr = new XMLHttpRequest()
				result = $.Promise()
				if $.is "function", opts
					opts = success: $.bound(xhr, opts)
				opts = $.extend {
					method: "GET"
					data: null
					state: $.identity 
					success: $.identity 
					error: $.identity 
					async: true
					asBlob: false
					timeout: 0 
					followRedirects: false
					withCredentials: false
					headers: {}
				}, opts
				opts.state = $.bound(xhr, opts.state)
				_success = $.bound(xhr, opts.success)
				_error = $.bound(xhr, opts.error)
				opts.success = (text) ->
					result.resolve(text)
					_success(text)
				opts.error = (err) ->
					result.reject(err)
					_error(err)
				if opts.data and opts.method is "GET"
					url += "?" + formencode(opts.data)
				else if opts.data and opts.method is "POST"
					opts.data = formencode(opts.data)
				xhr.open(opts.method, url, opts.async)
				xhr = $.extend xhr,
					asBlob: opts.asBlob
					timeout: opts.timeout
					followRedirects: opts.followRedirects
					withCredentials: opts.withCredentials
					onreadystatechange: ->
						opts.state?()
						if xhr.readyState is 4
							if xhr.status is 200
								opts.success xhr.responseText
							else
								opts.error xhr.status, xhr.statusText
				for k,v of opts.headers
					xhr.setRequestHeader k, v
				try xhr.addEventListener "progress", (evt) =>
					$.log("xhr progress event", evt.loaded, evt.total)
					result.emit('progress', evt.loaded, evt.total)
				xhr.send opts.data
				return $.extend result, cancel: -> xhr.cancel()
			post: (url, opts = {}) ->
				if $.is("function",opts)
					opts = success: opts
				opts.method = "POST"
				$.http(url, opts)
			get: (url, opts = {}) ->
				if( $.is("function",opts) )
					opts = success: opts
				opts.method = "GET"
				$.http(url, opts)
	}
$.depends 'hook', ->
	$.init.append (obj) ->
		map = new Map()
		keyMakers = []
		$.inherit {
			index: (keyMaker) ->
				if keyMakers.indexOf(keyMaker) is -1
					keyMakers.push keyMaker
					map.set(keyMaker, new Map())
				for x in @
					key = keyMaker x
					_map = map.get keyMaker
					unless _map.has key
						_map.set key, $()
					_map.get(key).push x
				@
			query: (criteria) ->
				for keyMaker in keyMakers
					_map = map.get keyMaker
					if _map.has key = keyMaker criteria
						for item in _map.get(key)
							return if (yield item) is false
				null
			queryOne: (criteria) ->
				@query(criteria).next().value
		}, obj
$.plugin
	provides: "toHTML"
	depends: "type,synth,once"
, ->
	dumpStyles = $.once -> try $("head").append $.synth("style#dump").text """
		table.dump                { border: 1px solid black; }
		table.dump tr.h           { background-color: blue; color: white; cursor: pointer; }
		table.dump tr.h th        { padding: 0px 4px; }
		table.dump tr.h.array     { background-color: purple; }
		table.dump tr.h.bling     { background-color: gold; }
		table.dump td             { padding: 2px; }
		table.dump td.k           { background-color: lightblue; }
		table.dump td.v.string    { background-color: #cfc; }
		table.dump td.v.number    { background-color: #ffc; }
		table.dump td.v.bool      { background-color: #fcf; }
	"""
	dumpScript = $.once -> try $("head").append $.synth("script#dump").text """
		$(document.body).delegate('table.dump tr.h', 'click', function() {
			$(this.parentNode).find("tr.kv").toggle()
		})
	"""
	table = (t, rows) ->
		tab = $.synth "table.dump tr.h.#{t} th[colspan=2] '#{t}'"
		if t in ["array","bling","nodelist"]
			tab.find("th").appendText " [#{rows.length}]"
		tab.append(row) for row in rows
		tab[0]
	tableRow = (k, v, open) ->
		row = $.synth "tr.kv td.k[align=right][valign=top] '#{k}' + td.v"
		td = row.find "td.v"
		switch _t = $.type v = $.toHTML v, open
			when "string","number","bool","html","null","undefined" then td.appendText String v
			else td.append v
		td.addClass _t
		row.toggle() unless open
		return row
	return { $: {
		toHTML: (obj, open=true) ->
			do dumpStyles
			do dumpScript
			return switch t = $.type obj
				when "string","number","bool","null","undefined","html" then obj
				when "bling","array","nodelist"
					table(t, tableRow(k, v, open) for v,k in obj)
				when "object","array"
					table(t, tableRow(k, v, open) for k,v of obj)
				when "node"
					s = $.HTML.stringify obj
					s.substr(0, s.indexOf('>') + 1) + '...'
				else String(obj)
	} }
$.plugin
	provides: 'keyName,keyNames'
	depends: "math"
, ->
	keyCode =
		"Backspace": 8
		"BS": 8
		"Tab": 9
		'\t': 9
		"Enter": 13
		'\n': 12
		"Shift": 16
		"Ctrl": 17
		"Alt": 18
		"Pause": 19
		"Break": 19
		"Caps": 20
		"Caps Lock": 20
		"Esc": 27
		"Escape": 27
		"Space": 32
		" ": 32
		"PgUp": 33
		"Page Up": 33
		"PgDn": 34
		"End": 35
		"Home": 36
		"Left": 37
		"Up": 38
		"Right": 39
		"Down": 40
		"Insert": 45
		"Del": 46
		"Delete": 46
		"Times": 106
		"*": 106
		"Plus": 107
		"+": 107
		"Minus": 109
		"-": 109
		"Div": 111
		"Divide": 111
		"/": 111
		"Semi-Colon": 186
		";": 187
		"Equal": 187
		"=": 187
		"Comma": 188
		",": 188
		"Dash": 189
		"-": 189
		"Dot": 190
		"Period": 190
		".": 190
		"Forward Slash": 191
		"/": 191
		"Back Slash": 220
		"\\": 220
		"Single Quote": 222
		"'": 222
	for a in "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
		keyCode[a] = keyCode[a.toLowerCase()] = a.charCodeAt(0)
	for a in $.range(1,13)
		keyCode["F"+a] = keyCode["f"+a] = 111 + a
	keyName = {}
	for name, code of keyCode
		keyName[code] or= name
	return $:
		keyCode: (name) -> keyCode[name] ? name
		keyName: (code) -> keyName[code] ? code
$.plugin
	depends: "dom,promise"
	provides: "lazy"
, ->
	lazy_load = (elementName, props) ->
		ret = $.Promise()
		document.head.appendChild elem = $.extend document.createElement(elementName), props,
			onload: -> ret.resolve elem
			onerror: -> ret.reject.apply ret, arguments
		ret
	$:
		script: (src) ->
			lazy_load "script", { src: src }
		style: (src) ->
			lazy_load "link", { href: src, rel: "stylesheet" }
$.plugin {
	provides: "log, logger"
	depends: "bound"
}, ->
	_t = { 
		_MS: "" 
		SS: "" 
		MM: ""
		HH: ""
		dd: ""
		mm: ""
		yyyy: ""
	}
	get_date_prefix = =>
		d = new Date()
		if _t._MS isnt ms = $.padLeft(d.getUTCMilliseconds(), 3, "0")
			_t._MS = ms
			if _t.SS isnt sec = $.padLeft d.getUTCSeconds(), 2, "0"
				_t.SS = sec
				if _t.MM isnt min = $.padLeft d.getUTCMinutes(), 2, "0"
					_t.MM = min
					if _t.HH isnt hr = $.padLeft String(d.getUTCHours()), 2, "0"
						_t.HH = hr
						if _t.dd isnt day = $.padLeft String(d.getUTCDate()), 2, "0"
							_t.dd = day
							if _t.mm isnt mon = $.padLeft String(d.getUTCMonth() + 1), 2, "0"
								_t.mm = mon
								_t.yyyy = String d.getUTCFullYear()
		"#{_t.yyyy}-#{_t.mm}-#{_t.dd} #{_t.HH}:#{_t.MM}:#{_t.SS}.#{_t._MS}"
	log = (a...) ->
		if a.length
			if p = log.pre?()
				a.unshift p
			log.out a...
			return a[a.length-1]
	log.out = console.log.bind console
	log.pre = null
	log.enableTimestamps = (level=2) ->
		log.pre = ([
			null
			-> String(+new Date())
			get_date_prefix
		])[level]
	log.disableTimestamps = -> log.enableTimestamps(0)
	return $: {
		log: log
		logger: (prefix) -> (a...) -> a.unshift prefix; log a...
	}
$.plugin
	provides: "matches"
	depends: "function,core,string"
, ->
	IsEqual = (p, o, t) -> (o is p)
	Contains = (p, a, t) ->
		for v in a when (matches p, v, t) then return true
		return false
	ContainsValue = (p, o, t) ->
		for k,v of o when (matches p, v, t) then return true
		return false
	ObjMatch = (p, o, t) -> 
		for k,v of p when not (matches v, o[k]) then return false
		return true
	ArrayMatch = (p, o, t) ->
		for v,i in p when not (matches v, o[i]) then return false
		return true
	RegExpMatch = (p, s, t) -> p.test String(s)
	behaviors = {
		"function": [
			['array', 'bling', Contains]
			['object', ContainsValue]
		]
		regexp: [
			['string','number', RegExpMatch ]
			['array','bling', Contains ]
			['object', ContainsValue ]
		]
		object: [
			['array','bling', Contains ]
			['object', ObjMatch ]
		]
		array: [
			['array','bling', ArrayMatch ]
		]
		number: [
			['number', IsEqual ]
			['array','bling', Contains ]
		]
		string: [
			['string', IsEqual ]
			['array','bling', Contains ]
		]
	}
	for pt,v of behaviors
		matches = { }
		for list in v
			f = list.pop()
			for obj_type in list
				matches[obj_type] = f
		$.type.extend pt, { matches }
	specialPatterns = {
		$any: -> true
		$type:  (p, o, t) -> $.is p.$type, o
		$class: (p, o, t) -> $.isType p.$class, o
		$lt:    (p, o, t) -> o < p.$lt
		$gt:    (p, o, t) -> o > p.$gt
		$lte:   (p, o, t) -> o <= p.$lte
		$gte:   (p, o, t) -> o >= p.$gte
		$ne:    (p, o, t) -> o != p.$ne
	}
	matches = (pattern, obj, pt = $.type.lookup pattern) ->
		if pt.name is 'object'
			for k, f of specialPatterns
				if k of pattern
					return f pattern, obj, pt
		for type, f of pt.matches
			continue if type is 'else'
			if $.is type, obj
				return f pattern, obj, pt
		return pt.matches?.else?(pattern, obj, pt) ? IsEqual pattern, obj, pt
	matches.Any = { $any: true }
	matches.Type = (type) -> { $type: type }
	matches.Class = (klass) -> { $class: klass }
	return $: matches: matches
$.plugin
	provides: "math"
	depends: "core"
, ->
	$.type.extend
		bool: { number: (o) -> if o then 1 else 0 }
		number: { bool: (o) -> not not o }
	_By = (cmp) ->
		(field) ->
			valueOf = switch
				when $.is "string", field then (o) -> o[field]
				when $.is "function", field then field
				else throw new Error ".maxBy first argument should be a string or function"
			x = @first()
			@skip(1).each (n) ->
				if cmp valueOf(n), valueOf(x)
					x = n
			x
	$:
		range: (start, end, step = 1) ->
			if not end? then (end = start; start = 0)
			step *= -1 if end < start and step > 0 
			$( (start + (i*step)) for i in [0...Math.ceil( (end - start) / step )] )
		zeros: (n, z = 0) -> $( z for i in [0...n] )
		ones: (n) -> $( 1 for i in [0...n] )
		deg2rad: (n) -> n * Math.PI / 180
		rad2deg: (n) -> n * 180 / Math.PI
	floats: -> @map parseFloat
	ints: -> @map -> parseInt @, 10
	px: (delta) -> @ints().map -> $.px @,delta
	min: -> @filter( isFinite ).reduce Math.min
	max: -> @filter( isFinite ).reduce Math.max
	maxBy: _By (a,b) -> a > b
	minBy: _By (a,b) -> a < b
	mean: mean = -> if not @length then 0 else @sum() / @length
	avg: mean
	sum: ->
		n = 0
		n += x for x in @ when x? and isFinite(x)
		n
	product: -> @filter( isFinite ).reduce (a) -> a * @
	squares: -> @pow(2)
	pow: (n) -> @map -> Math.pow @, n
	magnitude: -> Math.sqrt @floats().squares().sum()
	scale: (r) -> @map -> r * @
	add: add = (d) -> switch $.type(d)
		when "number" then @map -> d + @
		when "bling","array" then $( @[i]+d[i] for i in [0...Math.min(@length,d.length)] )
	plus: add
	sub: sub = (d) -> switch $.type d
		when "number" then @map -> @ - d
		when "bling","array" then $( @[i]-d[i] for i in [0...Math.min @length, d.length])
	minus: sub
	dot: (b) ->
		$.sum( @[i]*b[i] for i in [0...Math.min(@length,b.length)] )
	angle: (b) -> Math.acos (@dot(b) / (@magnitude() * b.magnitude()))
	cross: (b) ->
		$ @[1]*b[2] - @[2]*b[1],
			@[2]*b[0] - @[0]*b[2],
			@[0]*b[1] - @[1]*b[0]
	normalize: -> @scale 1 / @magnitude()
	deg2rad: -> @filter( isFinite ).map -> @ * Math.PI / 180
	rad2deg: -> @filter( isFinite ).map -> @ * 180 / Math.PI
#
$.plugin
	depends: "function,hash"
	provides: 'memoize'
, ->
	plainCache = ->
		data = {}
		return {
			has: (k) -> k of data
			get: (k) -> data[k]
			set: (k,v) -> data[k] = v
		}
	$:
		memoize: (opts) ->
			if $.is "function", opts
				opts = f: opts
			if not $.is 'object', opts
				throw new Error "Argument Error: memoize requires either a function or object as first argument"
			opts.cache or= plainCache()
			opts.hash or= $.hash
			return ->
				key = opts.hash arguments
				if opts.cache.has key then opts.cache.get key
				else opts.cache.set key, opts.f.apply @, arguments
$.plugin
	provides: 'middleware',
	depends: 'type'
, ->
	$: middleware: (s = []) -> 
		e = $() 
		{
			catch:  (f)   -> e.push f; @
			use:    (f)    -> s.push f                                  ; @
			unuse:  (f)    -> s.splice i, 1 while (i = s.indexOf f) > -1; @
			invoke: (a...) -> 
				i = -1
				do next = (=> try (s[++i] a..., next) catch _e then e.call _e)
				@
		}
$.plugin
	depends: "core,function"
	provides: "promise"
, ->
	class NoValue 
	Promise = (obj) ->
		if obj in [$.global, null, undefined]
			if this is $
				obj = {}
			else
				obj = this
		waiting = []
		err = result = NoValue
		consume_all = (e, v) ->
			while w = waiting.shift()
				consume_one w, e, v
			null
		consume_one = (cb, e, v) ->
			cb.timeout?.cancel()
			try cb e, v
			catch _e
				_stack = $.debugStack _e
				$.log "Promise(#{ret.promiseId}) first-chance exception:", _stack
				try cb _e, null
				catch __e
					__stack = $.debugStack __e
					$.log "Promise(#{ret.promiseId}) last-chance exception:", __stack
			null
		end = (error, value) =>
			if err is result is NoValue
				if error isnt NoValue
					err = error
					unless error?.stack 
						err = new Error error
				else if value isnt NoValue
					result = value
				switch true
					when value is @
						return end new TypeError "cant resolve a promise with itself"
					when value? and value.then and value.catch 
						value.then (x) -> end null, x
						value.catch (e) -> end e, null
					when $.is 'promise', value then value.wait end 
					when error isnt NoValue then consume_all err, null
					when value isnt NoValue then consume_all null, result
			return @
		ret = $.inherit {
			promiseId: $.random.string 6
			wait: (timeout, cb) -> 
				if $.is "function", timeout
					[cb, timeout] = [timeout, Infinity]
				if err isnt NoValue
					consume_one cb, err, null
				else if result isnt NoValue
					consume_one cb, null, result
				else 
					waiting.push cb 
					if isFinite parseFloat timeout
						cb.timeout = $.delay timeout, =>
							if (i = waiting.indexOf cb) > -1
								waiting.splice i, 1
								consume_one cb, (err = new Error 'timeout'), undefined
				@
			then: (f, e) -> @wait (err, x) ->
				if err then e?(err)
				else f(x)
			finish:  (value) -> end NoValue, value; @
			resolve: (value) -> end NoValue, value; @
			fail:    (error) -> end error, NoValue; @
			reject:  (error) -> end error, NoValue; @
			reset:  -> 
				err = result = NoValue; @
			handler: (err, data) ->
				if err then ret.reject(err) else ret.resolve(data)
			inspect: -> "{Promise[#{@promiseId}] #{getState()}}"
			toString: -> "{Promise[#{@promiseId}] #{getState()}}"
		}, $.EventEmitter(obj)
		getState = -> switch
			when result isnt NoValue then "resolved"
			when err isnt NoValue then "rejected"
			else "pending"
		isFinished = -> result isnt NoValue
		$.defineProperty ret, 'finished', get: isFinished
		$.defineProperty ret, 'resolved', get: isFinished
		isFailed = -> err isnt NoValue
		$.defineProperty ret, 'failed',   get: isFailed
		$.defineProperty ret, 'rejected', get: isFailed
		return ret
	Promise.compose = Promise.parallel = (promises...) ->
		promises = $(promises).flatten()
		p = $.Progress(1 + promises.length)
		$(promises).select('wait').call (err) ->
			if err then p.reject(err) else p.resolve 1
		p.resolve 1
	Promise.collect = (promises) ->
		ret = []
		p = $.Promise()
		unless promises? then return p.resolve(ret)
		q = $.Progress(1 + promises.length)
		for promise, i in promises then do (i) ->
			promise.wait (err, result) ->
				if err then q.reject(err) 
				else q.resolve 1, ret[i] = result 
		q.then (->p.resolve ret), p.reject
		q.resolve(1)
		p
	Promise.wrapCall = (f, args...) ->
		p = $.Promise()
		f args..., (e, r) ->
			if e then p.reject(e) else p.resolve(r)
		return p
	Progress = (max = 1.0) ->
		cur = 0.0
		return ret = $.inherit {
			progress: (args...) ->
				return cur unless args.length
				cur = args[0] ? cur
				max = (args[1] ? max) if args.length > 1
				item = if args.length > 2 then args[2] else cur
				if cur >= max
					ret.__proto__.__proto__.resolve(item)
				ret.emit 'progress', cur, max, item
				@
			resolve: (delta, item = delta) ->
				unless isFinite(delta) then delta = 1
				ret.progress cur + delta, max, item
			finish: (delta, item) -> ret.resolve delta, item
			include: (promise) ->
				if $.is 'promise', promise
					ret.progress cur, max + 1
					promise.wait (err, data) ->
						if err then ret.reject err
						else ret.resolve data
				@
			inspect: -> "{Progress[#{ret.promiseId}] #{cur}/#{max}}"
		}, Promise()
	Promise.xhr = (xhr) ->
		p = $.Promise()
		xhr.onreadystatechange = ->
			if @readyState is @DONE
				if @status is 200
					p.resolve xhr.responseText
				else
					p.resolve "#{@status} #{@statusText}"
		return p
	Promise.series = (series...) ->
		series = $(series).flatten()
		run = (i) -> ->
			if i >= series.length
				return
			series[i] = series[i]().wait (err, result) ->
				p.resolve series[i] = [ err, result ]
				$.immediate run i + 1
		p = $.Progress(series.length)
		$.immediate run 0
		return p
	$.depends 'dom', ->
		Promise.image = (src) ->
			p = $.Promise()
			$.extend image = new Image(),
				onerror: (e) -> p.reject e
				onload: -> p.resolve image
				src: src
			p
	$.depends 'type', ->
		$.type.register 'promise', is: (o) ->
			return o? \
				and ('object' is typeof o) \
				and 'then' of o \
				and 'function' is typeof o.then \
				and o.then.length is 2
	return $: { Promise, Progress }
$.plugin
	provides: 'prompt,confirm',
	depends: 'synth,keyName'
, ->
	_prompt_css = ->
		unless $("head .prompt").length
			$("head").append "<style class='prompt'>" + $.CSS.stringify(
				".prompt":
					position: "absolute"
					top: 0, left: 0
					width: "100%", height: "100%"
					zIndex: "999999"
					background: "rgba(0,0,0,.4)"
					fontSize: "12px"
					" input":
						padding: "2px"
						margin: "0px 0px 4px -4px"
						width: "100%"
					" button":
						fontSize: "13px"
						".done":
							fontSize: "14px"
					" > center":
						width: "200px"
						height: "44px"
						margin: "20px auto"
						padding: "16px"
						background: "#ffc"
						borderRadius: "5px"
			) + "</style>"
	_prompt = (label, type, cb) ->
		_prompt_css()
		dialog = $.synth("""
			div.prompt center
				input[type=#{type}][placeholder=#{label}] + br +
				button.cancel 'Cancel' +
				button.done 'Done'
		""").appendTo("body").first()
		input = dialog.querySelector("input")
		input.onkeydown = (evt) ->
			switch $.keyName evt.keyCode
				when "Enter"
					done input.value
				when "Esc"
					done null
		doneButton = dialog.querySelector "button.done"
		cancelButton = dialog.querySelector "button.cancel"
		done = (value) ->
			delete doneButton.onclick
			delete cancelButton.onclick
			dialog.parentNode.removeChild(dialog)
			cb value
		doneButton.onclick = -> done input.value
		cancelButton.onclick = -> done null
		null
	_confirm = (args...) ->
		cb = args.pop()
		label = args.shift()
		if args.length > 0
			buttons = args
		else
			buttons = { Yes: true, No: false }
		_prompt_css()
		dialog = $.synth("""
			div.prompt center
				span '#{label}' + br
		""").appendTo("body")
		center = dialog.find('center')
		switch $.type(buttons)
			when 'array','bling'
				for label in buttons
					$.synth("button[value=#{label}] '#{label}'").appendTo center
			when 'object'
				for label,value of buttons
					$.synth("button[value=#{value}] '#{label}'").appendTo center
		dialog.find("button").bind "click", (evt) ->
			dialog.remove()
			cb evt.target.getAttribute('value')
		null
	return $: { prompt: _prompt, confirm: _confirm }
$.plugin
	depends: "core"
	provides: "pubsub"
, ->
	class Hub
		constructor: ->
			@listeners = {} 
		publish: (channel, args...) ->
			caught = null
			for listener in @listeners[channel] or= []
				if @filter(listener, args...)
					try listener(args...)
					catch err
						caught ?= err
			if caught then throw caught
			switch args.length
				when 0 then null
				when 1 then args[0]
				else args
		filter: (listener, message) ->
			if 'patternObject' of listener
				return $.matches listener.patternObject, message
			return true
		publisher: (channel, func) -> 
			t = @ 
			-> t.publish channel, func.apply @, arguments
		subscribe: (channel, args...) ->
			func = args.pop()
			if args.length > 0
				func.patternObject = args.pop()
			(@listeners[channel] or= []).push func
			func
		unsubscribe: (channel, func) ->
			if not func?
				@listeners[channel] = []
			else
				a = (@listeners[channel] or= [])
				if (i = a.indexOf func)  > -1
					a.splice i,1
			func
	ret = { $: { Hub } }
	rootHub = new Hub()
	for name,prop of Object.getOwnPropertyDescriptors(Hub.prototype)
		continue if name is 'constructor'
		if "function" is typeof prop.value
			ret.$[name] = prop.value.bind rootHub
	return ret
$.plugin
	provides: 'random'
	depends: 'type'
, ->
	englishAlphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".split ""
	uuidAlphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	{ floor, abs, log } = Math
	max_int = 0xFFFFFFFF
	s = new Uint32Array(2)
	next = ->
		s0 = s[0]
		s1 = s[1]
		result = (s0 + s1) % max_int
		s1 ^= s0
		s[0] = (s0 << 27) | (s0 >>> 5) ^ s1 ^ (s1 << 7)
		s[1] = (s1 << 18) | (s1 >>> 14)
		return result
	random = -> next() / max_int
	$.defineProperty random, 'seed',
		set: (n) ->
			s[0] = n
			s[1] = 1
			next(); next(); next();
			n
	random.seed = +new Date()
	$: random: $.extend random,
			real: real = (min, max) ->
				if not min?
					[min,max] = [0,1.0]
				if not max?
					[min,max] = [0,min]
				(random() * (max - min)) + min
			integer: integer = (min, max) -> floor real min, max
			string: string = (len, prefix="", alphabet=englishAlphabet) ->
				prefix += element(alphabet) while prefix.length < len
				prefix
			coin: (balance=.5) -> random() <= balance
			element: element = (arr, weights) ->
				if weights?
					w = $(weights)
					w = w.scale 1.0/w.sum()
					i = 0
					sorted = $(arr).map((x) ->
						v: x
						w: w[i++]
					).sortBy (x) -> -x.w
					r = random()
					sum = 0
					for item in sorted
						return item.v if (sum += item.w) >= r
				return arr[integer 0, arr.length]
			gaussian: (mean=0.5, ssig=0.12) -> 
				while true
					u = random()
					v = 1.7156 * (random() - 0.5)
					x = u - 0.449871
					y = abs(v) + 0.386595
					q = (x*x) + y*(0.19600*y-0.25472*x)
					break unless q > 0.27597 and (q > 0.27846 or (v*v) > (-4*log(u)*u*u))
				return mean + ssig*v/u
			die: die = (faces) -> 
				integer 1, faces+1
			dice: (n, faces) -> 
				$( die(faces) for [0...n] by 1 )
			uuid: ->
				$(8,4,4,4,12).map(-> string @,'',uuidAlphabet).join '-'
$.plugin
	provides: "render"
	depends: "promise, type, logger"
, ->
	log = $.logger "[render]"
	consume_forever = (promise, opts, p = $.Promise()) ->
		unless $.is "promise", promise
			return $.Promise().resolve(reduce promise, opts)
		promise.wait (err, result) ->
			if err then return p.reject err
			r = reduce result, opts
			if $.is 'promise', r
				consume_forever r, opts, p
			else p.resolve(r)
		p
	render = (o, opts = {}) ->
		consume_forever r = (reduce [ o ], opts), opts
	
	object_handlers = {
		text: (o, opts) -> reduce o[opts.lang ? "EN"], opts
	}
	
	render.register = register = (t, f) -> object_handlers[t] = f
	render.reduce = reduce = (o, opts) -> 
		(t = $.type.lookup o).reduce(o, t, opts)
	$.type.extend
		unknown:   reduce: (o, t, opts) -> "[ cant reduce type: #{t} ]"
		string:    reduce: $.identity
		html:      reduce: $.identity
		null:      reduce: (o, t, opts) -> t
		undefined: reduce: (o, t, opts) -> t
		number:    reduce: (o, t, opts) -> String o
		function:  reduce: (o, t, opts) ->
			switch f.length
				when 0,1 then reduce f(opts)
				else $.Promise.wrap f, opts
		object: reduce: (o, t, opts) ->
			if (t = o.t ? o.type) of object_handlers
				object_handlers[t].call o, o, opts
			else "[ no handler for object type: '#{t}' #{JSON.stringify(o).substr 0,20}... ]"
		promise: reduce: (o, t, opts) ->
			q = $.Promise()
			o.wait finish_q = (err, result) ->
				return q.reject(err) if err
				if $.is 'promise', r = reduce result, opts
					r.wait finish_q
				else
					q.resolve r
			q
		array: reduce: array_reduce = (o, t, opts) ->
			p = $.Progress m = 1 
			q = $.Promise() 
			n = []
			p.wait (err) ->
				if err then q.reject(err) else q.resolve(finalize n, opts)
			has_promises = false
			for x, i in o then do (x,i) ->
				n[i] = y = reduce x, opts 
				if $.is 'promise', y
					has_promises = true
					p.progress null, ++m
					y.wait finish_p = (err, result) -> 
						return p.reject(err) if err
						rp = reduce result, opts
						if $.is 'promise', rp
							rp.wait finish_p
						else
							p.resolve n[i] = rp
			p.resolve(1) 
			if has_promises then q
			else finalize n
		bling: reduce: array_reduce
	finalize = (o, opts) ->
		(t = $.type.lookup o).finalize(o, t, opts)
	$.type.extend
		unknown:   finalize: (o, t, opts) -> "[ cant finalize type: #{t} ]"
		string:    finalize: $.identity
		html:      finalize: $.identity
		number:    finalize: (o, t, opts) -> String o
		array:     finalize: array_finalize = (o, t, opts) -> (finalize(x, opts) for x in o).join ''
		bling:     finalize: array_finalize
		null:      finalize: -> "null"
		undefined: finalize: -> "undefined"
	
	aka = (name) -> object_handlers[name]
	register 'link', (o, opts) -> [
		"<a"
			[" #{k}='",o[k],"'"] for k in ["href","name","target"] when k of o
		">",reduce(o.content,opts),"</a>"
	]
	register 'a', aka 'link'
	register 'let', (o, opts) ->
		save = opts[o.name]
		opts[o.name] = o.value
		ret = reduce o.content, opts
		if save is undefined then delete opts[o.name]
		else opts[o.name] = save
		return ret
	register 'set', aka 'let'
	register 'get', (o, opts) -> reduce opts[o.name], opts
	return $: { render }
$.plugin
	provides: "sortBy,sortedIndex,sortedInsert,groupBy"
, ->
	$:
		sortedIndex: (array, item, sorter, lo = 0, hi = array.length) ->
			cmp = switch true
				when $.is "string", sorter then (a,b) -> a[sorter] < b[sorter]
				when $.is "function", sorter then (a,b) -> sorter(a) < sorter(b)
				else (a,b) -> a < b
			while lo < hi
				mid = (hi + lo)>>>1
				if cmp array[mid], item
					lo = mid + 1
				else
					hi = mid
			return lo
	sortBy: (sorter) ->
		a = $()
		for item in @
			a.sortedInsert(item, sorter)
		a
	sortedInsert: (item, sorter) ->
		if @length is 0 then @push item
		else @splice ($.sortedIndex @, item, sorter), 0, item
		@
	groupBy: (sorter) ->
		groups = {}
		
		switch $.type sorter
			when 'array','bling'
				for x in @
					c = (x[k] for k in sorter).join ","
					(groups[c] or= $()).push( x)
			when 'string' then for x in @ then (groups[x[sorter]] or= $()).push( x)
			when 'function' then for x in @ then (groups[sorter(x)] or= $()).push( x)
		return $.valuesOf groups
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
	$: StateMachine: class StateMachine 
		@extractCode = (f, priorText='') -> 
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
				.replace(/return ([^;]+),(\d+)/, '$1;s=$2') \
				.replace('return ', 's = ') \
				.replace(/\s*}$/,'') \
				.replace(/;*(##N##|##R##)\s*/g,';') \
				.replace(/##R##/g, "\r") \
				.replace(/##N##/g, "\n") \
				.replace(/^\s+/,"") \
				.replace(/\s+$/,"") \
				.replace(/\r|\n/g,'') \
				? ""
		constructor: (table, debug=false) ->
			parse = null
			trace = debug and "$.log('state:',s,'i:',i,'c:',c);" or ""
			ret = "s=s|0;for(i=i|0;i<=d.length;i++){c=d[i]||'eof';#{trace}switch(s){"
			for state,rules of table 
				if 'enter' of rules 
					priorText = 'p=s;'
					onEnter = StateMachine.extractCode(rules.enter, priorText)
					onEnter = "if(s!==p){#{onEnter};if(s!==p){i--;break}}"
				else
					onEnter = ""
				hasRules = Object.keys(rules).length > (if 'enter' of rules then 1 else 0)
				ret += "case #{state}:#{onEnter}" \
					+ (hasRules and "switch(c){" or "break;\n")
				for _c,_code of rules
					continue if _c is 'enter' 
					ret += _c is 'def' and "default:" or "case '#{escapeAsKey _c}':"
					ret += StateMachine.extractCode(_code, priorText) + ";break;"
				ret += hasRules and "}break;" or ""
			ret += "}}return this;"
			try @run = (new Function "d", "s", "i", "p", "c", ret)
			catch err
				$.log "Failed to parse compiled machine: ", ret
				throw err
$.plugin
	provides: "string"
	depends: "type"
, ->
	safer = (f) -> (a...) ->
		try return f(a...)
		catch err then return "[toString Error: #{err.message}]"
	escape_single_quotes = (s) -> s.replace(/([^\\]{1})'/g,"$1\\'")
	strip_ansi_codes = (s) -> String(s).replace(/[\u001b\u009b][[()#;?]*(?:[0-9]{1,4}(?:;[0-9]{0,4})*)?[0-9A-ORZcf-nqry=><]/g,'')
	$.type.extend
		unknown:
			string: safer (o) -> o.toString?() ? String(o)
			repr: safer (o) -> $.type.lookup(o).string(o)
			number: safer (o) -> parseFloat String o
		null:
			string: -> "null"
		undefined:
			string: -> "undefined"
		buffer:
			string: safer (o) -> String(o)
			repr:   safer (o) -> "Buffer(#{JSON.stringify o.toJSON()})"
		string:
			number: safer parseFloat
			repr: (s) -> "'#{escape_single_quotes s}'"
		array:
			string: safer (a) -> "[#{a.map($.toString).join(', ')}]"
			repr:   safer (a) -> "[#{a.map($.toRepr).join(', ')}]"
		arguments:
			string: safer (a) -> "[#{($.toString(x) for x in a).join(', ')}]"
			repr: safer (a) -> "[#{($.toRepr(x) for x in a).join(', ')}]"
		object:
			string: safer (o) ->
				ret = []
				for k of o
					try v = o[k]
					catch err
						v = "[Error: #{err.message}]"
					ret.push "#{k}:#{$.toString v}"
				"{" + ret.join(', ') + "}"
			repr: safer (o) ->
				ret = []
				for k of o
					try v = o[k]
					catch err
						v = "[Error: #{err.message}]"
					ret.push "\"#{k}\": #{$.toRepr v}"
				"{" + ret.join(', ') + "}"
		function:
			repr: (f) -> f.toString()
			string: (f) -> f.toString().replace(/^([^{]*){(?:.|\n|\r)*}$/, '$1{ ... }')
		number:
			repr: (n) -> String(n)
			string: safer (n) -> switch
				when n.precision? then n.toPrecision(n.precision)
				when n.fixed? then n.toFixed(n.fixed)
				else String(n)
	return {
		$:
			toString: (x) ->
				if arguments.length is 0 then "function Bling() { [ ... ] }"
				else
					try
						$.type.lookup(x).string(x)
					catch err
						"[$.toString Error: #{err.message}]"
			toRepr: (x) -> $.type.lookup(x).repr(x)
			px: (x, delta=0) -> x? and (parseInt(x,10)+(parseInt(delta)|0))+"px"
			capitalize: (name) ->
				(name.split(" ").map (x) -> x[0].toUpperCase() + x.substring(1).toLowerCase()).join(" ")
			slugize: slugize = (phrase, slug="-") ->
				phrase = switch $.type phrase
					when 'null','undefined' then ""
					when 'object' then ($.slugize(k,slug) + slug + $.slugize(v, slug) for k,v of phrase).join slug
					when 'array','bling' then phrase.map((item)-> $.slugize item, slug).join slug
					else String(phrase)
				phrase.toLowerCase() \
					.replace(/^\s+/, '') \
					.replace(/\s+$/, '') \
					.replace(/\t/g, ' ') \
					.replace(/[^A-Za-z0-9. -]/g, '') \
					.replace(/\s+/g,'-')
			stubize: slugize
			dashize: (name) ->
				ret = ""
				for i in [0...(name?.length|0)]
					c = name.charCodeAt i
					if 91 > c > 64
						c += 32
						ret += '-'
					ret += String.fromCharCode(c)
				ret
			camelize: (name) ->
				name = $.slugize(name)
				name.split('-')
				while (i = name?.indexOf('-')) > -1
					name = $.stringSplice(name, i, i+2, name[i+1].toUpperCase())
				name
			commaize: (num, comma=',',dot='.',currency='') -> 
				if $.is('number', num) and isFinite(num)
					s = String(num)
					sign = if (num < 0) then "-" else ""
					[a, b] = s.split '.' 
					if a.length > 3 
						a = $.stringReverse $.stringReverse(a).match(/\d{1,3}/g).join comma
					return sign + currency + a + (if b? then dot+b else "")
				else if (typeof(num) is 'number' and isNaN(num)) or num in [Infinity, -Infinity]
					return String num
				else return undefined
			padLeft: (s, n, c = " ") ->
				dn = n - strip_ansi_codes(s).length
				return if dn > 0 then $.zeros(dn, c).join('') + s
				else s
			padRight: (s, n, c = " ") ->
				dn = n - strip_ansi_codes(s).length
				return if dn > 0 then s + $.zeros(dn, c).join ''
				else s
			stringTruncate: (s, n, c='...',sep=' ') -> 
				return s if s.length <= n
				return c if c.length >= n
				s = s.split(sep) 
				r = []
				while n > 0
					x = s.shift()
					n -= x.length
					if n >= 0
						r.push x
				r.join(sep) + c
			stringCount: (s, x, i = 0, n = 0) ->
				if (j = s.indexOf x,i) > i-1
					$.stringCount s, x, j+1, n+1
				else n
			stringSplice: (s, i, j, n) ->
				nn = s.length
				end = j
				if end < 0
					end += nn
				start = i
				if start < 0
					start += nn
				s.substring(0,start) + n + s.substring(end)
			stringReverse: (s) -> s.split('').reverse().join('')
			checksum: (s) ->
				a = 1; b = 0
				for i in [0...s.length]
					a = (a + s.charCodeAt(i)) % 65521
					b = (b + a) % 65521
				(b << 16) | a
			repeat: (x, n=2) -> switch
				when n is 1 then x
				when n < 1 then ""
				when $.is "string", x then $.zeros(n, x).join ''
				else $.zeros(n, x)
			stringBuilder: do ->
				len = (s) -> s?.toString().length | 0
				->
					if $.is("global", @) then return new $.stringBuilder()
					items = []
					$.extend @,
						length: 0
						append:  (s) => items.push s; @length += len s
						prepend: (s) => items.splice 0,0,s; @length += len s
						clear:       => ret = @toString(); items = []; @length = 0; ret
						toString:    -> items.join("")
		toString: -> $.toString @
		toRepr: -> $.toRepr @
		replace: (patt, repl) ->
			@map (s) -> s.replace(patt, repl)
		indexOf: (target, offset=0) ->
			if $.is 'regexp', target
				for i in [offset...@length] by 1
					if target.test @[i]
						return i
				return -1
			else Array.prototype.indexOf.apply @, arguments
	}
$.plugin
	provides: "symbol"
	depends: "type"
, ->
	symbol = null
	cache = {}
	g = $.global
	g['Bling'] = $
	if module?
		module.exports = $
	$.defineProperty $, "symbol",
		set: (v) ->
			g[symbol] = cache[symbol]
			cache[symbol = v] = g[v]
			g[v] = Bling
		get: -> symbol
	return $:
		symbol: "$"
		noConflict: ->
			$.symbol = "Bling"
			Bling
$.plugin
	provides: "synth"
	depends: "StateMachine, type, dom"
, ->
	class SynthMachine extends $.StateMachine
		common = 
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
		
		rule = (a...) -> $.extend a...
		constructor: (debug=false) ->
			super [
				enter:   ->
						@tag = @id = @cls = @attr = @val = @text = ""
						@attrs = {}
						1
				rule { def: (c) ->  @tag += c; 1 }, common
				rule { def: (c) ->  @id += c; 2 }, common
				rule { def: (c) ->  @cls += c; 3 }, common,
					enter: -> @cls += (@cls.length and " " or ""); 3
					".":   -> @cls += " "; 3 
				rule { def: (c) ->  @attr += c; 4 }, no_eof,
					"=":   -> 5
					"]":   -> @attrs[@attr] = @val; @attr = @val = ""; 1
				rule { def: (c) ->  @val += c; 5 }, no_eof,
					"]":   -> @attrs[@attr] = @val; @attr = @val = ""; 1
				rule { def: (c) ->  @text += c; 6 }, no_eof,
					'\\':  -> 8 
					'"':   -> @emitText()
				rule { def: (c) ->  @text += c; 7 }, no_eof,
					'\\':  -> 9 
					"'":   -> @emitText()
				rule { def: (c) ->  @text += c; 6 }, no_eof
				rule { def: (c) ->  @text += c; 7 }, no_eof
			], debug
			@reset()
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
		htmlType = $.type.lookup("<html>")
		emitText: ->
			@emitNodeAndReparent()
			@text?.length \
				and @cursor.appendChild htmlType.node(@text) \
				or @text = ""
			0
	machine = new SynthMachine()
	return $: synth: (expr) ->
		f = machine.reset().run(expr, 0).fragment
		return $(if f.childNodes.length is 1 then f.childNodes[0] else f)
$.plugin
	depends: "StateMachine, function"
	provides: "template"
, -> 
	current_engine = null
	engines = {}
	template = {
		register_engine: (name, render_func) ->
			engines[name] = render_func
			if not current_engine?
				current_engine = name
		render: (text, args) ->
			if current_engine of engines
				engines[current_engine](text, args)
	}
	template.__defineSetter__ 'engine', (v) ->
		if not v of engines
			throw new Error "invalid template engine: #{v} not one of #{Object.Keys(engines)}"
		else
			current_engine = v
	template.__defineGetter__ 'engine', -> current_engine
	template.__defineGetter__ 'engines', -> $.keysOf(engines)
	template.register_engine 'null', do ->
		return $.identity
	match_forward = (text, find, against, start, stop = -1) ->
		count = 1
		if stop < 0
			stop = text.length + 1 + stop
		for i in [start...stop] by 1
			t = text[i]
			if t is against
				count += 1
			else if t is find
				count -= 1
			if count is 0
				return i
		return -1
	template.register_engine 'pythonic', do ->
		type_re = /([0-9#0+-]*)\.*([0-9#+-]*)([diouxXeEfFgGcrsqm])((?:.|\n)*)/
		chunk_re = /%[\(\/]/
		compile = (text) ->
			chunks = text.split chunk_re
			n = chunks.length
			ret = [chunks[0]]
			j = 1 
			for i in [1...n] by 1
				end = match_forward chunks[i], ')', '(', 0, -1
				if end is -1
					return "Template syntax error: unmatched '%(' starting at: #{chunks[i].substring(0,15)}"
				key = chunks[i].substring 0, end
				rest = chunks[i].substring end
				match = type_re.exec rest
				if match is null
					return "Template syntax error: invalid type specifier starting at '#{rest}'"
				rest = match[4]
				ret[j++] = key
				ret[j++] = match[1]|0
				ret[j++] = match[2]|0
				ret[j++] = match[3]
				ret[j++] = rest
			return ret
		compile.cache = {}
		return render = (text, values) -> 
			cache = compile.cache[text] 
			if not cache?
				cache = compile.cache[text] = compile(text) 
			output = [cache[0]] 
			j = 1 
			n = cache.length
			for i in [1..n-5] by 5
				[key, pad, fixed, type, rest] = cache[i..i+4]
				value = values[key]
				if not value?
					value = "missing value: #{key}"
				output[j++] = switch type
					when 'd' then "" + parseInt(value, 10)
					when 'f' then parseFloat(value).toFixed(fixed)
					when 's' then "" + value
					else "" + value
				if pad > 0
					output[j] = $.padLeft output[j], pad
				output[j++] = rest
			output.join ""
	return $: { template }
$.plugin
	provides: "throttle"
	depends: "core"
, ->
	defer = (f, ctx, args, ms, to) ->
		clearTimeout to
		to = setTimeout (=>
			f.apply ctx, args
		), ms
		return to
	throttle = (f, ctx, args, ms, last) ->
		if (dt = $.now - last) > ms
			last += dt
			f.apply ctx, args
		return last
	$:
		throttle: (ms, f) ->
			last = 0
			->
				last = throttle f, @, arguments, ms, last
				null
		debounce: (ms, f) ->
			timeout = null
			->
				a = arguments
				timeout = defer f, @, arguments, ms, timeout
				null
		rate_limit: (ms, f) ->
			"""
			rate_limit is a combination of throttle and debounce.
			 what we want from a stream throttle is to fire at most every _ms_ and
			 then fire one last time after a gap of _ms_ at the end.
			"""
			last = 0
			timeout = null
			->
				a = arguments
				timeout = defer f, @, arguments, ms, timeout
				last = throttle f, @, arguments, ms, last
				null
$.plugin
	provides: 'TNET'
	depends: "type, string, function"
, -> 
	#
	
	Types =
		"number":
			symbol: "#"
			pack: String
			unpack: Number
		"string":
			symbol: "'"
			pack: $.identity
			unpack: $.identity
		"bool":
			symbol: "!"
			pack: (b) -> String(not not b)
			unpack: (s) -> s is "true"
		"null":
			symbol: "~"
			pack: -> ""
			unpack: -> null
		"undefined":
			symbol: "_"
			pack: -> ""
			unpack: -> undefined
		"array":
			symbol: "]"
			pack: (a) -> (packOne(y) for y in a).join('')
			unpack: (s) ->
				data = []
				unpackingStack.push data
				while s.length > 0
					[one, s] = unpackOne(s)
					data.push(one)
				unpackingStack.pop()
				data
		"map":
			symbol: "M"
			pack: (m) ->
				ret = ''
				m.forEach (v, k) ->
					ret += packOne(k)+packOne(v)
				ret
			unpack: (s) ->
				m = new Map()
				unpackingStack.push m
				while s.length > 0
					[k, s] = unpackOne(s)
					[v, s] = unpackOne(s)
					m.set(k, v)
				unpackingStack.pop()
				m
		"bling":
			symbol: "$"
			pack: (a) -> (packOne(y) for y in a).join('')
			unpack: (s) ->
				data = $()
				unpackingStack.push data
				while s.length > 0
					[one, s] = unpackOne(s)
					data.push(one)
				unpackingStack.pop()
				data
		"object":
			symbol: "}"
			pack: (o) ->
				(packOne(k)+packOne(v) for k,v of o when k isnt "constructor" and o.hasOwnProperty(k)).join ''
			unpack: (s) ->
				data = {}
				unpackingStack.push data
				while s.length > 0
					[key, s] = unpackOne(s)
					[value, s] = unpackOne(s)
					data[key] = value
				unpackingStack.pop()
				data
		"function":
			symbol: ")"
			pack: (f) ->
				s = f.toString().replace(/(?:\n|\r)+\s*/g,' ')
				name = ""
				name_re = /function\s*(\w+)\(.*/g
				if name_re.test s
					name = s.replace name_re, "$1"
				parts = s.replace(/function\s*\w*\(/,'')
					.replace(/\/\*.*\*\//g,'')
					.replace(/}$/,'')
					.split(/\) {/)
				args = parts[0].split /, */
				body = parts.slice(1).join(') {')
					.replace(/^\s+/,'')
					.replace(/\s*$/,'')
				return $( name, args, body ).map(packOne).join ''
			unpack: (s) ->
				[name, rest] = unpackOne(s)
				[args, rest] = unpackOne(rest)
				[body, rest] = unpackOne(rest)
				try return makeFunction name, args.join(), body
				catch err
					$.log "Failed to makeFunction."
					$.log "Arguments:", args.join()
					$.log "Body:", body
		"regexp":
			symbol: "/"
			pack: (r) -> String(r).slice(1,-1)
			unpack: (s) -> RegExp(s)
		"class":
			symbol: "{"
			pack: (o) ->
				return [ Types.function.pack(o), packOne( o.prototype, "object" ) ].join ''
			unpack: (s) ->
				[s, rest] = unpackOne s
				f = eval s
				[f.prototype, rest] = unpackOne rest
				f
		"class instance":
			symbol: "C"
			pack: (o) ->
				unless 'constructor' of o
					throw new Error("TNET: cant pack non-class as class")
				unless o.constructor of class_index
					throw new Error("TNET: cant pack unregistered class (name: #{o.constructor.name})")
				ret = packOne(class_index[o.constructor])
				packingStack.pop() 
				ret + packOne(o, "object") 
			unpack: (s) ->
				[i, rest] = unpackOne(s)
				[obj, rest] = unpackOne(rest)
				if i <= classes.length
					obj.__proto__ = classes[i - 1].prototype
				else
					(unpackingStack.splice(0, unpackingStack.length))
					throw new Error("TNET: attempt to unpack unregistered class index: #{i}")
				obj
		"circular reference":
			symbol: "@"
			pack: (i) -> String i
			unpack: (s) ->
				unpackingStack[parseInt s, 10]
	makeFunction = (name, args, body) ->
		eval("var f = function #{name}(#{args}){#{body}}")
		return f
	classes = []
	class_index = {}
	register = (klass) ->
		class_index[klass] or= classes.push klass
	reverseLookup = {} 
	do -> for t,v of Types
		reverseLookup[v.symbol] = v
	unpackingStack = []
	unpackOne = (data) ->
		if data and (i = data.indexOf ":") > 0 
			di = parseInt data[0...i], 10 
			if isFinite(di) and $.is 'number', di 
				if i < (x = i + 1 + di) < data.length 
					if sym = reverseLookup[data[x]] 
						return [ 
							sym.unpack(data[i+1...x]),
							data[x+1...]
						]
		return [ undefined, data ]
	packingStack = [] 
	packOne = (x, forceType) ->
		tx = forceType ? $.type x
		if tx is "unknown" and not (x.constructor?.name in [undefined, "Object"])
			tx = "class instance"
		unless (t = Types[tx])?
			(packingStack.splice(0, packingStack.length))
			throw new Error("TNET: I don't know how to pack type '#{tx}' (#{x.constructor?.name})")
		if (i = packingStack.indexOf x) > -1
			t = Types["circular reference"]
			x = i 
		packingStack.push(x)
		try
			data = t.pack(x)
		catch err
			(packingStack.splice(0, packingStack.length))
			throw err
		packingStack.pop()
		return (data.length) + ":" + data + t.symbol
	$:
		TNET:
			Types: Types
			registerClass: register
			stringify: packOne
			parse: (x) -> Bling.TNET.parseOne(x)?[0]
			parseOne: (x) -> 
				if Buffer.isBuffer x
					x = x.toString()
				unpackOne(x)
$.plugin
	provides: "trace"
	depends: "function,type,logger"
, ->
	$.type.extend
		unknown:  { trace: $.identity }
		object:   { trace: (label, o, tracer) ->
			(o[k] = $.trace(o[k], "#{label}.#{k}", tracer) for k in Object.keys(o))
			o
		}
		array:    { trace: (label, o, tracer) ->
			(o[i] = $.trace(o[i], "#{label}[#{i}]", tracer) for i in [0...o.length] by 1)
			o
		}
		bling:    { trace: (label, o, tracer) ->
			(o[i] = $.trace(o[i], "#{label}[#{i}]", tracer) for i in [0...o.length] by 1)
			o
		}
		function: { trace: (label, f, tracer) ->
			label or= f.name
			r = (a...) ->
				start = +new Date
				f.apply @, a
				label = "#{@name or $.type(@)}.#{label}"
				args = $(a).map($.toRepr).join ','
				elapsed = (+new Date - start).toFixed 0
				tracer "#{label}(#{args}): #{elapsed}ms"
			r.toString = -> "{Trace '#{label}' of #{f.toString()}"
			r
		}
	time = (label, f, logger) ->
		unless $.is "string", label
			[f, logger, label] = [label, f, "trace"]
		unless $.is "function", logger
			logger = $.log
		start = +new Date
		ret = do f
		logger "[#{label}] #{(+new Date - start).toFixed 0}ms"
		return ret
	return $:
		time: time
		trace: (label, o, tracer) ->
			unless $.is "string", label
				[tracer, o] = [o, label]
			tracer or= $.log
			label or= ""
			$.type.lookup(o).trace(label, o, tracer)
$.plugin
	depends: "dom"
, ->
	COMMASEP = ", "
	speeds = 
		"slow": 700
		"medium": 500
		"normal": 300
		"fast": 100
		"instant": 0
		"now": 0
	accel_props_re = /(?:scale(?:3d)*|translate(?:[XYZ]|3d)*|rotate(?:[XYZ]|3d)*)/
	updateDelay = 30 
	testStyle = document.createElement("div").style
	transformProperty = "transform"
	transitionProperty = "transition-property"
	transitionDuration = "transition-duration"
	transitionTiming = "transition-timing-function"
	if "WebkitTransform" of testStyle
		transformProperty = "-webkit-transform"
		transitionProperty = "-webkit-transition-property"
		transitionDuration = "-webkit-transition-duration"
		transitionTiming = "-webkit-transition-timing-function"
	else if "MozTransform" of testStyle
		transformProperty = "-moz-transform"
		transitionProperty = "-moz-transition-property"
		transitionDuration = "-moz-transition-duration"
		transitionTiming = "-moz-transition-timing-function"
	else if "OTransform" of testStyle
		transformProperty = "-o-transform"
		transitionProperty = "-o-transition-property"
		transitionDuration = "-o-transition-duration"
		transitionTiming = "-o-transition-timing-function"
	return {
		$:
			duration: (speed) ->
				d = speeds[speed]
				return d if d?
				return parseFloat speed
		transform: (end_css, speed, easing, callback) ->
			if $.is("function",speed)
				callback = speed
				speed = easing = null
			else if $.is("function",easing)
				callback = easing
				easing = null
			speed ?= "normal"
			easing or= "ease"
			duration = $.duration(speed) + "ms"
			props = []
			trans = ""
			css = {}
			for i of end_css
				if accel_props_re.test(i)
					ii = end_css[i]
					if ii.join
						ii = $(ii).px().join COMMASEP
					else if ii.toString
						ii = ii.toString()
					trans += " " + i + "(" + ii + ")"
				else css[i] = end_css[i]
			(props.push i) for i of css
			if trans
				props.push transformProperty
			css[transitionProperty] = props.join COMMASEP
			css[transitionDuration] = props.map(-> duration).join COMMASEP
			css[transitionTiming] = props.map(-> easing).join COMMASEP
			if trans
				css[transformProperty] = trans
			@css css
			if callback
				@delay duration, $.bound @, callback
		hide: (callback) -> 
			@each ->
				if @style
					@_display = "" 
					if @style.display is not "none"
						@_display = @syle.display
					@style.display = "none"
			.trigger("hide")
			if callback
				@delay updateDelay, $.bound @, callback
			@
		show: (callback) -> 
			@each ->
				if @style
					@style.display = @_display
					delete @_display
			.trigger("show")
			if callback
				@delay updateDelay, $.bound @, callback
			@
		toggle: (callback) -> 
			@weave(@css("display"))
				.fold((display, node) ->
					if display is "none"
						node.style.display = node._display or ""
						delete node._display
						$(node).trigger "show"
					else
						node._display = display
						node.style.display = "none"
						$(node).trigger "hide"
					node
				).delay(updateDelay, $.bound @, callback)
		fadeIn: (speed, callback) -> 
			@.css('opacity','0.0')
				.show ->
					@transform {
						opacity:"1.0",
						translate3d: [0,0,0]
					}, speed, callback
		fadeOut: (speed, callback, x = 0.0, y = 0.0) -> 
			@transform {
				opacity:"0.0",
				translate3d:[x,y,0.0]
			}, speed, -> @hide($.bound @, callback)
		fadeLeft: (speed, callback) -> @fadeOut speed, callback, "-"+@width().first(), 0.0
		fadeRight: (speed, callback) -> @fadeOut speed, callback, @width().first(), 0.0
		fadeUp: (speed, callback) -> @fadeOut speed, callback, 0.0, "-"+@height().first()
		fadeDown: (speed, callback)  -> @fadeOut speed, callback, 0.0, @height().first()
	}
$.plugin
	provides: 'Trie'
, -> 
	class Trie
		constructor: ->
			@length = 0
		insert: (item, key=String item) -> return insert @, item, key.toLowerCase(), 0
		insert = (t, item, key, n) ->
			t.length++
			if n < key.length
				o = t.children or= {}
				insert (o[key[n]] or= new Trie),
					item, key, n+1
			else
				(t.values or= []).push item
			t
		find: (prefix) -> return find @, prefix.toLowerCase(), 0
		find = (t, k, n) ->
			end = n >= k.length
			if end and t.values
				for v in t.values
					break if (yield v) is false
			else for c,child of t.children
				if end or c is k[n]
					`yield* find(child,k,n+1)`
			null	
	
	return { $: { Trie } }
$.plugin
	provides: "type,is,inherit,extend,defineProperty,isType,are,as,isSimple,isDefined,isEmpty"
	depends: "compat"
, ->
	__toString = Object.prototype.toString
	isType = (T, o) ->
		if not o? then T in [o,"null","undefined"]
		else (o.constructor? and (o.constructor is T or o.constructor.name is T)) or
			__toString.apply(o) is "[object #{T}]" or
			isType T, o.__proto__ 
	inherit = (parent, objs...) ->
		return unless objs.length > 0
		obj = objs.shift()
		if typeof parent is "function"
			parent = parent.prototype
		if parent.__proto__ in [Object.prototype, null, undefined]
			parent.__proto__ = obj.__proto__
		obj.__proto__ = parent
		if objs.length > 0
			return inherit obj, objs...
		else obj
	_type = do ->
		cache = {}
		base =
			name: 'unknown'
			is: -> true
		order = []
		_with_cache = {} 
		_with_insert = (method, type) ->
			a = (_with_cache[method] or= [])
			if (i = a.indexOf type) is -1
				a.push type
		register = (name, data) ->
			data.is or= -> false
			if name of cache
				return _extend name, data
			order.unshift name if not (name of cache)
			cache[data.name = name] = if (base isnt data) then (inherit base, data) else data
			cache[name][name] = (o) -> o
			for key of cache[name]
				_with_insert key, cache[name]
			return cache[name]
		_extend = (name, data) ->
			if typeof name is "string"
				cache[name] or= register name, {}
				cache[name] = extend cache[name], data
				for method of data
					_with_insert method, cache[name]
			else if typeof name is "object"
				(_extend k, name[k]) for k of name
			null
		lookup = (obj) ->
			for name in order
				if cache[name].is.call obj, obj
					return cache[name]
			null
		register "unknown",   base
		register "object",    is: (o) -> o? and (typeof o is "object") and (o.constructor?.name in [undefined, "Object"])
		register "array",     is: Array.isArray or (o) -> isType Array, o
		register "map",       is: (o) -> o and (o instanceof Map)
		register "buffer",    is: $.global.Buffer.isBuffer or -> false 
		register "error",     is: (o) -> isType 'Error', o
		register "regexp",    is: (o) -> isType 'RegExp', o
		register "string",    is: (o) -> typeof o is "string" 
		register "number",    is: (o) -> typeof o is "number" and not isNaN(o)
		register "bool",      is: (o) -> typeof o is "boolean" 
		register "function",  is: (o) -> typeof o is "function"
		register "class",     is: (o) -> typeof o is "function" and ('prototype' of (props = Object.getOwnPropertyDescriptors o)) and not ('arguments' of props)
		register "global",    is: (o) -> typeof o is "object" and 'setInterval' of o
		register "arguments", is: (o) -> typeof o is "object" and 'callee' of o and 'length' of o
		register "undefined", is: (x) -> x is undefined
		register "null",      is: (x) -> x is null
		return extend ((o) -> lookup(o).name),
			register: register
			lookup: lookup
			extend: _extend
			get: (t) -> cache[t]
			is: (t, o) -> cache[t]?.is.call(o, o) ? false
			as: (t, o, rest...) -> lookup(o)[t]?(o, rest...)
			with: (f) -> _with_cache[f] ? []
	_type.extend
		unknown:   { array: (o) -> [o] }
		null:      { array:     -> [] }
		undefined: { array:     -> [] }
		array:     { array: (o) -> o }
		number:    { array: (o) -> $.extend new Array(o), length: 0 }
		arguments: { array: (o) -> Array.prototype.slice.apply o }
	maxHash = 0xFFFFFFFF
	_type.register "bling",
		is:     (o) -> o and isType $, o
		array:  (o) -> (o and o.toArray()) or []
		hash:   (o) -> o.map($.hash).reduce (a,x) -> ((a*a)+x) % maxHash
		string: (o) -> $.symbol + "([" + o.map((x) -> $.type.lookup(x).string(x)).join(", ") + "])"
		repr:   (o) -> $.symbol + "([" + o.map((x) -> $.type.lookup(x).repr(x)).join(", ") + "])"
	_type.in = (types..., obj) ->
		for type in types
			return true if $.is type, obj
		return false
	$:
		inherit: inherit
		extend: extend
		defineProperty: (o, name, opts) ->
			Object.defineProperty o, name, extend({ configurable: true, enumerable: true }, opts)
			o
		isType: isType
		type: _type
		is: _type.is
		are: (type, args...) ->
			for a in args
				return false unless $.is type, a
			return true
		as: _type.as
		isDefined: (o) -> o?
		isSimple: (o) -> _type.in "string", "number", "bool", o
		isEmpty: (o) -> o in ["", null, undefined] \
			or o.length is 0 or (typeof o is "object" and Object.keys(o).length is 0)
	defineProperty: (name, opts) -> @each -> $.defineProperty @, name, opts
$.plugin
	depends: 'math'
	provides: 'units'
, ->
	units = $ ["px","pt","pc","em","%","in","cm","mm","ex","lb","kg","yd","ft","m", ""]
	UNIT_RE = null
	do makeUnitRegex = ->
		joined = units.filter(/.+/).join '|'
		UNIT_RE = new RegExp "(\\d+\\.*\\d*)((?:#{joined})/*(?:#{joined})*)$"
	parseUnits = (s) ->
		if UNIT_RE.test(s)
			return UNIT_RE.exec(s)[2]
		""
	conv = (a,b) ->
		[numer_a, denom_a] = a.split '/'
		[numer_b, denom_b] = b.split '/'
		if denom_a? and denom_b?
			return conv(denom_b, denom_a) * conv(numer_a, numer_b)
		if a of conv and (b of conv[a])
			return conv[a][b]()
		0
	locker = (x) -> -> x
	fill = ->
	set = (from, to, f) ->
		conv[from] or= {}
		conv[from][to] = f
		if units.indexOf(from) is -1
			units.push from
		if units.indexOf(to) is -1
			units.push to
		makeUnitRegex()
		fill()
	init = ->
		$.type.register "units",
			is: (x) -> typeof x is "string" and UNIT_RE.test(x)
			number: (x) -> parseFloat(x)
			string: (x) -> "'#{x}'"
		set 'pc', 'pt', -> 12
		set 'in', 'pt', -> 72
		set 'in', 'px', -> 96
		set 'in', 'cm', -> 2.54
		set 'm', 'ft', -> 3.281
		set 'yd', 'ft', -> 3
		set 'cm', 'mm', -> 10
		set 'm', 'cm', -> 100
		set 'm', 'meter', -> 1
		set 'm', 'meters', -> 1
		set 'ft', 'feet', -> 1
		set 'km', 'm', -> 1000
		set 'em', 'px', ->
			w = 0
			try
				x = $("<span style='font-size:1em;visibility:hidden'>x</span>").appendTo("body")
				w = x.width().first()
				x.remove()
			w
		set 'ex', 'px', ->
			w = 0
			try
				x = $("<span style='font-size:1ex;visibility:hidden'>x</span>").appendTo("body")
				w = x.width().first()
				x.remove()
			w
		set 'ex', 'em', -> 2
		set 'rad', 'deg', -> 57.3
		set 's', 'sec', -> 1
		set 's', 'ms', -> 1000
		set 'ms', 'ns', -> 1000000
		set 'min', 'sec', -> 60
		set 'hr', 'min', -> 60
		set 'hr', 'hour', -> 1
		set 'hr', 'hours', -> 1
		set 'day', 'hr', -> 24
		set 'day', 'days', -> 1
		set 'y', 'year', -> 1
		set 'y', 'years', -> 1
		set 'y', 'd', -> 365.25
		set 'g', 'gram', -> 1
		set 'g', 'grams', -> 1
		set 'kg', 'g', -> 1000
		set 'lb', 'g', -> 453.6
		set 'lb', 'oz', -> 16
		set 'f', 'frame', -> 1
		set 'f', 'frames', -> 1
		set 'sec', 'f', -> 60
		do fill = ->
			conv[''] = {}
			one = locker 1.0
			for a in units
				conv[a] or= {}
				conv[a][a] = conv[a][''] = conv[''][a] = one
			infered = 1
			while infered > 0
				infered = 0
				for a in units when a isnt ''
					conv[a] or= {}
					for b in units when b isnt ''
						if (not conv a,b) and (conv b,a)
							conv[a][b] = locker 1.0/conv(b,a)
							infered += 1
						for c in units when c isnt ''
							if (conv a,b) and (conv b,c) and (not conv a,c)
								conv[a][c] = locker conv(a,b) * conv(b,c)
								infered += 1
			null
		$.units.enable = ->
	convert = (unit, number) ->
		f = parseFloat(number)
		u = parseUnits(number)
		c = conv(u, unit)
		unless isFinite(c) and isFinite(f)
			return number
		"#{f * c}#{unit}"
	{
		$:
			units:
				enable: init
				set: set
				get: conv
				convertTo: convert
		convertTo: (unit) -> @map (x) -> convert unit, x
		unitMap: (f) ->
			@map (x) ->
				f.call((n = parseFloat x), n) + parseUnits x
	}
$.plugin
	depends: "type",
	provides: "url,URL"
, ->
	url_re = /\b(?:([a-z+]+):)(?:\/{1,2}([^?\/#]*?))(\/[^?]*)*(?:\?([^#]+))*(?:#([^\s]+))*$/i
	user_pass_re = /^([^:]+):([^@]+)@/
	username_re = /^([^:@]+)@/
	host_port_re = /^([^:]+):(\d+)/
	parse_host = (host) ->
		return {} unless host? and host.length > 0
		ret = { host }
		if ret.host.indexOf(",") > -1 then $.extend ret, {
			hosts: ret.host.split(",").map(parse_host)
			host: undefined
		} else
			if (m = ret.host.match user_pass_re) then $.extend ret, {
				username: m[1]
				password: m[2]
				host: ret.host.replace user_pass_re, ''
			} else if (m = ret.host.match username_re) then $.extend ret, {
				username: m[1]
				host: ret.host.replace username_re, ''
			}
			if (m = ret.host.match host_port_re) then $.extend ret, {
				host: m[1]
				port: m[2]
			}
		return ret
	parse = (str, parseQuery=false) ->
		ret = if (m = str?.match url_re) then {
			protocol: m[1]
			host:     m[2]
			path:     m[3]
			query:    m[4]?.replace /^\?/,''
			hash:     m[5]?.replace /^#/, ''
		} else null
		if ret?
			if parseQuery
				query = ret.query ? ""
				ret.query = Object.create null
				for pair in query.split('&')
					if (i = pair.indexOf '=') > -1
						ret.query[pair.substring 0,i] = unescape pair.substring i+1
					else if pair.length > 0
						ret.query[pair] = null
				delete ret.query[""]
			$.extend ret, parse_host(ret.host)
			$.keysOf(ret).each (key) ->
				switch $.type ret[key]
					when "null","undefined" then delete ret[key]
					when "string" then if ret[key].length is 0 then delete ret[key]
				null
		ret
	clean = (val, re, prefix = '', suffix ='') ->
		x = val ? ""
		return if x and not re.test x then prefix+x+suffix else x
	stringify = (url) ->
		if $.is 'object', url.query
			url.query = ("#{k}=#{v}" for k,v of url.query).join("&")
		return [
			clean(url.protocol, /:$/, '', ':'),
			clean(url.host, /^\//, '//'),
			clean(url.port, /^:/, ':'),
			clean(url.path, /^\//, '/'),
			clean(url.query, /^\?/, '?'),
			clean(url.hash, /^#/, '#')
		].join ''
	return $: URL: { parse, stringify }
$.plugin
	provides: "watchProperty"
	depends: "type"
, ->
	OP_CHANGE = 'change' 
	OP_INSERT = 'insert' 
	OP_DELETE = 'delete' 
	
	watchProperty = (obj, key, cb, prefix="") -> 
		if typeof key is 'string' and (i = key.indexOf ".") > -1
			first = key.substr 0,i
			return watchProperty obj[first], (key.substr i+1), cb, ((prefix?.length and prefix+'.'+ first) or  first)
		if $.is 'array', obj[key]
			watchArray obj[key], cb, ((prefix?.length and prefix+'.'+ key) or  key)
		prop = Object.getOwnPropertyDescriptor(obj, key)
		$.defineProperty obj, key,
			get: get = (prop.get ? -> prop.value)
			set: $.compose ($.partial cb, OP_CHANGE, ((prefix?.length and prefix+'.'+ key) or  key)), \
				(prop.set or (prop.writable and (v) -> prop.value = v) or get)
	watchArray = (arr, cb, prefix="") ->
		pcb = (op, key, value) ->
			cb op, ((prefix?.length and prefix+'.'+ key) or  key), value
		_watch = (method, _cb) ->
			supr = arr[method]
			arr[method] = (a...) ->
				try return supr.apply arr, a
				finally _cb.apply arr, a
		
		do rebindAll = ->
			for i in [0...arr.length] by 1
				watchProperty arr, i, pcb
			null
		
		_watch 'push', (item) ->
			i = @length - 1
			watchProperty @, i, pcb
			pcb OP_INSERT, i, item
		_watch 'unshift', (item) ->
			rebindAll()
			pcb OP_INSERT, 0, item
		_watch 'pop', ->
			pcb OP_DELETE, @length, 1
		_watch 'shift', ->
			rebindAll()
			pcb OP_DELETE, @length, 1
		_watch 'splice', (i, n, v) ->
			if v isnt undefined
				i += 1
				n -= 1
			else if n > 0
				i = @length
			if n > 0
				pcb OP_DELETE, i, n
		arr
	return { $: { watchProperty } }
