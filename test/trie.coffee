
[$, assert] = require './setup'

assert.generatorEqual = (g, a) ->
    i = 0
    for item from g
        assert.deepEqual item, a[i]
        i++

describe "Trie", ->
    it "works", ->
        t = new $.Trie()
        t.insert("abc")
        assert.generatorEqual t.find("abc"), [ "abc" ]
    it "finds prefixes", ->
        t = new $.Trie()
        t.insert("abc").insert("abd").insert("def")
        assert.generatorEqual t.find("ab"), [ "abc", "abd" ]
    it "finds prefixes (reversed order)", ->
        t = new $.Trie()
        t.insert("def").insert("abd").insert("abc")
        assert.generatorEqual t.find("ab"), [ "abd", "abc" ]
    it "can find nothing", ->
        t = new $.Trie()
        assert.generatorEqual t.find("ab"), [ ]
    it "works with keys and items", ->
        t = new $.Trie()
        t.insert( { a: 1 }, "abc" )
        t.insert( { b: 2 }, "def" )
        assert.generatorEqual t.find("de"), [ { b: 2 } ]