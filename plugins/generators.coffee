$.plugin ->

	# make the Generator prototype Great Again!
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

	# just return a no-op plugin because we are now automatically the best
	return { }