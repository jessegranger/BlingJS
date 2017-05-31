$.plugin
	provides: 'Trie'
, -> # Trie plugin

	class Trie
		constructor: ->
			@length = 0
		insert: (item, key=String item) -> return insert @, item, key, 0
		insert = (t, item, key, p) ->
			t.length++
			if p < key.length
				o = t.children or= {}
				k = key[p].toLowerCase()
				insert (o[k] or= new Trie),
					item, key, p+1
			else
				(t.values or= []).push item
			t
		find: (prefix) -> return find @, prefix, 0
		find = (t, prefix, p) ->
			end = p >= prefix.length
			if end and t.values
				for v in t.values
					return null if (yield v) is false
			for c,child of t.children
				if end or (c is prefix[p].toLowerCase())
					`yield* find(child,prefix,p+1)`
			null	
	
	return { $: { Trie } }