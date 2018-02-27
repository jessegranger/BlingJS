$.plugin {
	provides: "log, logger"
	depends: "bound"
}, ->

	# attempt to do less work prepending a formatted timestamp to the log
	_t = { # we will manually format each part on it's own to avoid full reformatting each time
		_MS: "" # as we check each level of precision higher
		SS: "" # if it hasnt changed then we stop formatting
		MM: ""
		HH: ""
		dd: ""
		mm: ""
		yyyy: ""
	}
	get_date_prefix = =>
		d = new Date()
		# all these ugly cases cause a short-circuit to only format as much of the date as we need
		# this is still not totally perfect, but it is wayyy faster
		# if two log lines happen on the same millsecond exactly N seconds apart with nothing between
		# then the seconds will get printed wrong
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
