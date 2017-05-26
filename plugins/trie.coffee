$.plugin
	provides: 'Trie'
, -> # Trie plugin

	class Trie
		constructor: ->
			@length = 0
		insert: (item, key, p=0) ->
			@length++
			if p < key.length
				c = key[p].toLowerCase()
				@children or= {}
				(@children[c] or= new Trie()) 
					.insert item, key, p+1
			else
				@values or= []
				@values.push item 
			@
		find: (prefix) -> return find @, prefix, 0
		find = (t, prefix, p) ->
			end = p >= prefix.length
			if end and t.values
				for v in t.values
					return null if (yield v) is false
			for c,child of t.children when end or (c is prefix[p].toLowerCase())
				`yield* find(child,prefix,p+1)`
			null	
	
	return { $: { Trie } }