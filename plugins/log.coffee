$.plugin {
	provides: "log, logger"
	depends: "bound"
}, ->

	# attempt to do less work prepending a formatted timestamp to the log
	ts = { # we will manually format each part to avoid full reformatting each time
		ms: "" # as we check each level of precision higher
		SS: "" # if it hasnt changed, then we stop formatting
		MM: ""
		HH: ""
		dd: ""
		mm: ""
		yyyy: ""
	}
	prior_date = 0
	get_date_prefix = ->
		d = new Date()
		delta = d - prior_date
		prior_date = d
		# all these ugly cases cause a short-circuit to only format as much of the date as changed
		if (ts.ms isnt ms = $.padLeft(d.getUTCMilliseconds(), 3, "0")) or (delta % 1000) is 0
			ts.ms = ms
			if ts.SS isnt sec = $.padLeft d.getUTCSeconds(), 2, "0" or (delta % 60000) is 0
				ts.SS = sec
				if ts.MM isnt min = $.padLeft d.getUTCMinutes(), 2, "0" or (delta % 3600000) is 0
					ts.MM = min
					if ts.HH isnt hr = $.padLeft String(d.getUTCHours()), 2, "0" or (delta % 86400000) is 0
						ts.HH = hr
						if ts.dd isnt day = $.padLeft String(d.getUTCDate()), 2, "0" or (delta > 86400000)
							ts.dd = day
							if ts.mm isnt mon = $.padLeft String(d.getUTCMonth() + 1), 2, "0"
								ts.mm = mon
								ts.yyyy = String d.getUTCFullYear()
		"#{ts.yyyy}-#{ts.mm}-#{ts.dd} #{ts.HH}:#{ts.MM}:#{ts.SS}.#{ts.ms}"

	log = (a...) ->
		if a.length
			p = log.pre()
			buf = []
			# fill up buf with all the lines
			for x,i in a
				x = $.toString x
				if -1 is x.indexOf '\n' then buf.push x
				else x.split('\n').forEach (y) ->
					if y?.length > 0
						buf.push y
						if p then buf.unshift p
						log.out buf...
						buf = []
			if buf.length > 0
				if p then buf.unshift p
				log.out buf...
			return a[a.length-1]
		null
	$.defineProperty log, "out", { configurable: false, writable: true }
	log.out = console.log.bind console
	prefixers = [
		-> null
		-> String(+new Date())
		get_date_prefix
	]
	do log.disableTimestamps = -> log.pre = prefixers[0]
	log.enableTimestamps = (level=2) -> log.pre = prefixers[level] ? prefixers[0]

	return $: {
		log: log
		logger: (prefix) -> (a...) -> log prefix, a...
	}
