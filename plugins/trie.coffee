$.plugin
	provides: 'Trie'
, -> # Trie plugin

	lc = (c) -> c.toLowerCase()

	class Trie
		constructor: ->
			@length = 0
		insert: (item, key=String item) -> return insert @, item, key.toLowerCase(), 0
		insert = (t, item, key, n) ->
			t.length++
			if n < key.length
				o = t.children or= {}
				insert (o[key[n]] or= new Trie),
					item, key, n+1
			else
				(t.values or= []).push item
			t
		find: (prefix) -> return find @, prefix.toLowerCase(), 0
		find = (t, k, n) ->
			end = n >= k.length
			if end and t.values
				for v in t.values
					break if (yield v) is false
			else for c,child of t.children
				if end or c is k[n]
					`yield* find(child,k,n+1)`
			null	
	
	return { $: { Trie } }
