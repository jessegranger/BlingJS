
$.plugin
	depends: "core,function"
	provides: "promise"
, ->

	class NoValue # a named totem

	Promise = (obj) ->
		if obj in [$.global, null, undefined]
			if this is $
				obj = {}
			else
				obj = this

		# There is an array of waiting functions.
		waiting = []

		err = result = NoValue

		# When either err or result arrives,
		# consume_all notifies all the functions in the waiting array.
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
					unless error?.stack # force all errors to capture the current stack
						err = new Error error
				else if value isnt NoValue
					result = value
				switch true
					# fatal error: passing a promise to it's own resolver
					when value is @
						return end new TypeError "cant resolve a promise with itself"
					# but, you can resolve one promise with another:
					when value? and value.then and value.catch # new ES6 Promise objects
						value.then (x) -> end null, x
						value.catch (e) -> end e, null
					when $.is 'promise', value then value.wait end # our internal Promise object
					# every waiting callback gets consumed and called
					when error isnt NoValue then consume_all err, null
					when value isnt NoValue then consume_all null, result
			return @

		ret = $.inherit {
			promiseId: $.random.string 6
			wait: (timeout, cb) -> # .wait([timeout], callback) ->
				if $.is "function", timeout
					[cb, timeout] = [timeout, Infinity]
				if err isnt NoValue
					consume_one cb, err, null
				else if result isnt NoValue
					consume_one cb, null, result
				else # this promise hasn't been resolved OR rejected yet
					waiting.push cb # so save this callback for later
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
			reset:  -> # blasphemy!
				# I am really sure now that we should not empty the waiting array here.
				# If there are items in the waiting array, then reset() is a no-op.
				# Because, if either err or result had a value,
				# then everything in waiting would have been consumed already.
				err = result = NoValue; @
			handler: (err, data) ->
				# use 'ret' here instead of '@' to prevent binding issues later
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
		# always an extra one for setup, so an empty list is finished immediately
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
				if err then q.reject(err) # any sub-failure is actual failure
				else q.resolve 1, ret[i] = result # put the results in the correct order
		q.then (->p.resolve ret), p.reject
		q.resolve(1)
		p

	Promise.wrapCall = (f, args...) ->
		p = $.Promise()
		f args..., (e, r) ->
			if e then p.reject(e) else p.resolve(r)
		return p

	# Progress is a multi-step promise, where you get notified at each step.
	# After the final step is complete, the underlying promise is resolved.
	Progress = (max = 1.0) ->
		cur = 0.0
		return ret = $.inherit {
			# .progress() - returns current progress
			# .progress(cur) - sets progress
			# .progress(cur, max) - set progress and goal
			# .progress(null, max) - set goal
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

	# Helper for wrapping an XHR object in a Promise
	Promise.xhr = (xhr) ->
		p = $.Promise()
		xhr.onreadystatechange = ->
			if @readyState is @DONE
				if @status is 200
					p.resolve xhr.responseText
				else
					p.resolve "#{@status} #{@statusText}"
		return p

	# process a series of functions that return promises
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
