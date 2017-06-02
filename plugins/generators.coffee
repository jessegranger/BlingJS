$.plugin ->
	# make the Generator prototype Great Again!
	Object.assign (do -> yield).constructor.prototype, {
		toArray: -> (x for x from this)
		skip: (n) -> @next() for i in [0...n]; @
		limit: (n) ->
			for x from this
				if n-- > 0 then yield x
				else return
		map: (f) -> yield f(x) for x from this
		filter: (f, v=true) -> yield x for x from this when f(x) is v
		select: (key) ->
			yield select(x, key) for x from this
	}
	select = (o, k) ->
		if (i = k.indexOf '.') > -1 then select o[k.substr 0, i], k.substr i+1
		else o[k]
	return {}

