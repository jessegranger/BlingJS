$.depends 'hook', ->
	$.init.append (obj) ->
		map = new Map()
		keyMakers = []
		$.inherit {
			index: (keyFunc) ->
				if keyMakers.indexOf(keyFunc) is -1
					keyMakers.push keyFunc
					map.set(keyFunc, new Map())
				for x in @
					key = keyFunc x
					_map = map.get keyFunc
					unless _map.has key
						_map.set key, $()
					_map.get(key).push x
				@
			query: (criteria) ->
				for keyMaker in keyMakers
					_map = map.get keyMaker
					if _map.has key = keyMaker criteria
						for item in _map.get(key)
							return if (yield item) is false
				null
			queryOne: (criteria) ->
				@query(criteria).next().value
		}, obj

