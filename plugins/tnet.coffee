$.plugin
	provides: 'TNET'
	depends: "type, string, function"
, -> # TnetStrings plugin
	# TNET is a serialization format. Not human-readable.
	# Intended to be very simple to parse and extensible.
	# This implementation supports many more types than the original;
	# including the ability to register custom classes at runtime.
	#
	#define CLEAR(array) (array.splice(0, array.length))
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
				return makeFunction name, args.join(), body
		"regexp":
			symbol: "/"
			pack: (r) -> String(r).slice(1,-1)
			unpack: (s) -> RegExp(s)
		"class instance":
			symbol: "C"
			pack: (o) ->
				unless 'constructor' of o
					throw new Error("TNET: cant pack non-class as class")
				unless o.constructor of class_index
					throw new Error("TNET: cant pack unregistered class (name: #{o.constructor.name})")
				ret = packOne(class_index[o.constructor])
				packingStack.pop() # allow re-pack of o without triggering circular reference
				ret + packOne(o, "object") # re-pack o as a plain object
			unpack: (s) ->
				[i, rest] = unpackOne(s)
				[obj, rest] = unpackOne(rest)
				if i <= classes.length
					obj.__proto__ = classes[i - 1].prototype
				else
					CLEAR(unpackingStack)
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

	reverseLookup = {} # Reverse lookup table, for use during unpacking
	do -> for t,v of Types
		reverseLookup[v.symbol] = v

	unpackingStack = []
	unpackOne = (data) ->
		if data and (i = data.indexOf ":") > 0 # not -1, it shouldn't be first
			di = parseInt data[0...i], 10 # read a number (the length of the content)
			if isFinite(di) and $.is 'number', di # rules out NaN, Infinity, etc
				if i < (x = i + 1 + di) < data.length # move the read marker to the end
					if sym = reverseLookup[data[x]] # read the type symbol
						return [ # use the type to unpack the data
							sym.unpack(data[i+1...x]),
							data[x+1...]
						]
		return [ undefined, data ]

	packingStack = [] # a stack of the current packing objects
	packOne = (x, forceType) ->
		tx = forceType ? $.type x
		if tx is "unknown" and not (x.constructor?.name in [undefined, "Object"])
			tx = "class instance"
		unless (t = Types[tx])?
			CLEAR(packingStack)
			throw new Error("TNET: I don't know how to pack type '#{tx}' (#{x.constructor?.name})")
		if (i = packingStack.indexOf x) > -1
			t = Types["circular reference"]
			x = i # save the index into the packing stack
			# the theory is that this index will be the same during unpacking

		packingStack.push(x)
		try
			data = t.pack(x)
		catch err
			CLEAR(packingStack)
			throw err
		packingStack.pop()
		return (data.length) + ":" + data + t.symbol

	$:
		TNET:
			Types: Types
			registerClass: register
			stringify: packOne
			parse: (x) -> Bling.TNET.parseOne(x)?[0]
			parseOne: (x) -> # returns [value, leftOver] so you can continue reading a sequence
				if Buffer.isBuffer x
					x = x.toString()
				unpackOne(x)
