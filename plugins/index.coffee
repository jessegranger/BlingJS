$.depends 'hook', ->
	$.init.append (obj) ->
		map = new Map()
		keyMakers = []
		$.inherit {
			index: (keyMaker) ->
				if keyMakers.indexOf(keyMaker) is -1
					keyMakers.push keyMaker
					map.set(keyMaker, new Map())
				for x in @
					key = keyMaker x
					_map = map.get keyMaker
					unless _map.has key
						_map.set key, $()
					_map.get(key).push x
				@
			query: (criteria) ->
				for keyMaker in keyMakers
					_map = map.get keyMaker
					if _map.has key = keyMaker criteria
						return _map.get(key)
				return $()
			queryOne: (criteria) ->
				return @query(criteria)[0]
		}, obj

