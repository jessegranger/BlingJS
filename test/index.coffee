[$, assert] = require './setup'

readAll = (g) -> (x for x from g)

describe "Index/Query plugin:", ->
	describe ".index(keyMaker)", ->
		keyMaker = (obj) -> obj.a
		it "creates a private index", ->
			$([{a:1,b:2}, {a:2,b:3}]).index keyMaker
		it "cannot query until index has been built", ->
			assert.deepEqual readAll($([1,2,3]).query(a:1)), []
		it "can .query() after indexing", ->
			a = $([{a:1,b:'b'},{a:2},{a:3}]).index keyMaker
			assert.equal a.queryOne(a:1).b, 'b'
		it "can use compound keys", ->
			compoundKeyMaker = (obj) -> obj.a + "-" + obj.b
			a = $([{a:1,b:'b'},{a:2,b:1},{a:3,b:2,c:'c'}]).index compoundKeyMaker
			assert.equal a.queryOne(a:3,b:2).c, 'c'
		describe "using more than one key maker", ->
			keyMakerOne = (obj) -> obj.a
			keyMakerTwo = (obj) -> obj.b
			keyMakerThree = (obj) -> obj.a + '-' + obj.b
			a = $([{a:1,b:'b'},{a:2,b:1},{a:3,b:2,c:'c'}])
			it "wont hurt if you re-index by the same keyMaker", ->
				a.index keyMakerOne
				a.index keyMakerOne
				assert.equal a.queryOne(a:3).b, 2
			it "will allow querying against a second keyMaker", ->
				a.index keyMakerTwo
				assert.equal a.queryOne(a:3).b, 2
				assert.equal a.queryOne(b:2).a, 3
			it "will allow querying against N keyMakers", ->
				a.index keyMakerOne
				a.index keyMakerTwo
				a.index keyMakerThree
				assert.equal a.queryOne(a:3).b, 2
				assert.equal a.queryOne(b:'b').a, 1
				assert.equal a.queryOne({a:3,b:2}).c, 'c'
