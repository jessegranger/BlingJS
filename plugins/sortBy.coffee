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
			n = $.sortedIndex a, item, sorter
			a.splice n, 0, item
		a
	sortedInsert: (item, sorter) ->
		@splice ($.sortedIndex @, item, sorter), 0, item
		@
	groupBy: (sorter) ->
		groups = {}
		#define ADD_TO_GROUP(G,X) (groups[G] or= $()).push(X)
		switch $.type sorter
			when 'array','bling'
				for x in @
					c = (x[k] for k in sorter).join ","
					ADD_TO_GROUP(c, x)
			when 'string' then for x in @ then ADD_TO_GROUP(x[sorter], x)
			when 'function' then for x in @ then ADD_TO_GROUP(sorter(x), x)
		return $.valuesOf groups

