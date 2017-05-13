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
						for item in _map.get(key)
							return if (yield item) is false
				null
			queryOne: (criteria) ->
				@query(criteria).next().value
		}, obj

