$.plugin
	provides: "sortBy,sortedIndex,sortedInsert,groupBy"
, ->
	$:
		sortedIndex: (array, item, sorter, lo = 0, hi = array.length) ->
			cmp = switch true
				# if its a property name, read the property
				when $.is "string", sorter then (a,b) -> a[sorter] < b[sorter]
				# if its a function, sort on the return value
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
			a.sortedInsert(item, sorter)
		a
	sortedInsert: (item, sorter) ->
		if @length is 0 then @push item
		else @splice ($.sortedIndex @, item, sorter), 0, item
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

