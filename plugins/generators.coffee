$.plugin ->
	# make the Generator prototype Great Again!
	Object.assign (do -> yield).constructor.prototype, {
		toArray: -> a = []; a.push(x) for x from this; a
		skip: (n) -> @next() for i in [0...n]; @
		limit: (n) ->
			for x from this
				if n-- > 0 then yield x
				else return
		map: (f) ->
			yield f(x) for x from this
			null
		filter: (f, v=true) ->
			yield x for x from this when f(x) is v
			null
		select: (key) ->
			yield select(x, key) for x from this
			null
	}
	select = (o, k) ->
		o = o[x] for x in k.split('.')
		o
	return { }

