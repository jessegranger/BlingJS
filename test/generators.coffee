[$, assert] = require './setup'

describe "Generators", ->
	it "should get new methods", ->
		assert.equal (typeof (do -> yield).toArray), 'function'
	describe "toArray", ->
		it "returns an Array", ->
			assert.equal $.type( (do -> yield "a").toArray() ), 'array' 
		it "contains all items", ->
			assert.deepEqual (do -> yield "a"; yield "b").toArray(), [ "a", "b" ]
	describe "skip", ->
		it "returns a generator", ->
			f = (do -> yield "a"; yield "b")
			g = f.skip(1)
			assert.equal (typeof g.next), 'function'
			assert.deepEqual g.toArray(), [ "b" ]
	describe "limit", ->
		it "returns a generator", ->
			f = ( do -> i = 0; while ++i then yield i ) # infinite generator
			g = f.limit(10)
			assert.deepEqual g.toArray(), [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]
	describe "map", ->
		it "returns a generator", ->
			f = ( do -> i = 0; while ++i then yield i ) # infinite generator
			g = f.map (x) -> x*2
			assert.deepEqual g.limit(5).toArray(), [ 2, 4, 6, 8, 10 ]
	describe "filter", ->
		it "returns a generator", ->
			f = ( do -> i = 0; while ++i then yield i ) # infinite generator
			g = f.filter (x) -> (x % 3) == 0
			assert.deepEqual g.limit(5).toArray(), [ 3, 6, 9, 12, 15 ]
	describe "select", ->
		it "returns a generator", ->
			g = do ->
				yield { a: [ 1, 2, 3 ] }
				yield { a: [ 2, 4, 6 ] }
			f = g.select('a.2')
			assert.deepEqual f.toArray(), [ 3, 6 ]
