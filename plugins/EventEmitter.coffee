$.plugin
	provides: "EventEmitter"
	depends: "type,hook"
, ->
	# EventEmitter Plugin
	# -------------------
	# The EventEmitter interface that NodeJS uses is much simpler (and
	# faster) than the DOM event model.  With this plugin, every new bling
	# becomes an EventEmitter automatically, you can extend a class from it:
	# `class Foo extends $.EventEmitter`, or you can mix it in to an instance:
	# `obj = $.EventEmitter(obj)`.
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
			setMaxListeners:        -> # who really needs this in the core API?
			listeners:          (e) -> list(e).slice 0
		}, obj
