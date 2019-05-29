$.plugin
	provides: "cartesian"
, ->
	$:
		cartesian: (sets...) ->
			n = sets.length
			ret = []
			helper = (cur, i) ->
				if ++i >= n
					return ret.push cur
				for x in sets[i]
					helper (cur.concat x), i
				null
			helper [], -1
			return $(ret)
