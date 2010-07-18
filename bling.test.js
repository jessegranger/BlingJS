
true == (function() {


	// define a unit testing framework:
	// any function can be tested inline
	// function f() { ... }.test(function() { ... }) === f
	// f.test().test() === f
	var tests = []
	Function.prototype.test = function(t) {
		var f = this
		tests.push(function() {
			try { t.call(f) } catch ( e ) {
				throw new Error(["test",t,"failed on",f,"with error",unescape(e)].join(" "))
			}
		})
		this.tested = true
		return this
	}
	// then immediately test the test framework!
	Function.prototype.test.test(function() {
		assert(true)
	})
	var runAllTests = function() {
		var pass = 0
		var start = new Date()
		while(tests.length) {
			try {
				tests.shift()()
				pass += 1
			} catch( err ) {
				console.log("test failed", err)
			}
		}
		console.log(pass, "tests passed in", (new Date() - start), "ms")
		var report = function(obj, label) {
			var untested = []
			var tested = total = 0
			for( var i in obj)
				if( isFunc(obj[i]) ) {
					total++
					if( obj[i].tested )
						tested++
					//else console.log("warning:",i,"untested")
					else
						untested.push(i)
				}
			console.log("test coverage:",tested,"of",total,label+",",Math.floor(tested*100/total),"percent")
			console.log("untested", untested)
		}
		report(Bling, "globals")
		report(Bling.prototype, "methods")
		Function.prototype.test = undefined
	}.test(function(){
		/* this test always passes */
		if( window.console )
			console.log("running",tests.length+1,"tests")
	})

	// define our asserts for use in tests
	function assert(a, msg) {
		assertEqual(!(a), false, msg)
	}
	function assertEqual(a, b, msg) {
		if( a != b ) throw new Error("assertion error: "+escape(a)+" != "+escape(b)+" "+ msg)
	}

	// register some tests for basic Bling creation
	Bling.test(function() { /* bling can be empty */
		assertEqual(new Bling().length, 0)
	})
	.test(function() { /* bling can create new html */
		assertEqual(new Bling("<a /><a /><a />").length, 3)
	})
	.test(function() {
		assertEqual(new Bling("<div><div /><div /></div>").length, 1)
	})
	.test(function() { /* blings can hold anything if you give a list */
		assertEqual(new Bling([1, 2, 3]).length, 3)
	})
	.test(function() { /* just a number: pre-allocate but dont fill */
		assertEqual(new Bling(100).length, 0)
	})
	.test(function() { /* wrap a single object of unknown type */
		assertEqual(new Bling({a:'b'}).zip('a').join(""), "b")
	})
	.test(function() { /* make sure the _right_ div is the one returned */
		assertEqual(new Bling("<div id='a'><div id='b' /><div id='c' /></div>").zip('id').toString(), '["a"]')
	})
	.test(function() { /* create a bling using a context */
		assertEqual(new Bling("div", new Bling("<div id='a'><div id='b' /><div id='c' /></div>")).zip('id').toString(), '["b", "c"]')
	})

	// add tests for the most basic globals
	Bling.extend.test(function() {
		var a = {a: 0, c: 3}
		var b = {a: 1, b: 2}
		var c = Bling.extend(a,b)
		assertEqual(c['a'], 1)
		assertEqual(c['b'], 2)
		assertEqual(c['c'], 3)
	})

	Bling.addMethods.test(function() {
		Bling.addMethods({"nop": function(){ return this; }})
		assert(isFunc(Bling.prototype.nop))
		Bling.prototype.nop = undefined
	})

	Bling.addGlobals.test(function() {
		Bling.addGlobals({"nop": function(x){ return x; }})
		assert(isFunc(Bling.nop))
		Bling.nop = undefined
	})

	Bling.bound.test(function() {
		var b = "abc"
		var f = b.toUpperCase.bound(b)
		assertEqual(f(), "ABC")
	})

	Bling.inheritsFrom.test(function() {
		function NewType() {
			Bling.apply(this, [])
			this.newAttribute = 42;
		}
		NewType.inheritsFrom(Bling)
		var n = new NewType()
		assertEqual(n.newAttribute, 42)
		assertEqual(n.length, 0) // inherited from Bling, which inherits from Array
	})

	Bling.operator.test(function() {
		assert(isFunc(Bling.operator))
		assert(isBling(Bling.operator()))
	})

	Bling.dumpText
		.test(function() { assertEqual( this({a: 'b'}), '{\n\ta: "b",\n}'); })
		.test(function() { assertEqual( this("a"), '"a"') })
	
	Bling.prototype.each
		.test(function() {
			var visit = {3: 2, 2: 3, 1: 1};
			var b = new Bling([1,2,3,2,3,2]);
			b.each(function() {
				visit[this] -= 1;
			});
			assertEqual(visit[1], 0);
			assertEqual(visit[2], 0);
			assertEqual(visit[3], 0);
		})

	Bling.prototype.map
		.test(function() {
			var b = new Bling([1,2,3,4,5]);
			var c = this.call(b, function() {
				return this * this;
			});
			assertEqual(b.length, c.length);
			for( var i = 0; i < c.length; i++) {
				assertEqual(b[i],i+1);
				assertEqual(c[i],(i+1)*(i+1));
			}
		})

	Bling.prototype.reduce
		.test(function() {
			var b = new Bling(["a", "b", "c"]);
			assertEqual(b.reduce(function(a){ return this + a; }), "cba");
			assertEqual(new Bling().reduce(function(a){ return this + a; }), undefined);
		})

	Bling.prototype.filter
		.test(function() {
			assertEqual(new Bling([1,2,3,4,5,6,7,8,9,10]).filter(function() { return this % 2 == 0; }).join(" "), "2 4 6 8 10")
		})

	Bling.prototype.distinct
		.test(function() {
			assertEqual(new Bling([1,2,1,3,4,5,2,3,3,2,1,1,4,5]).distinct().join(" "), "1 2 3 4 5")
		})
		.test(function() {
			var a = new Bling("<div>");
			a = a.concat(new Bling("body")).concat([a[0]])
			assertEqual(a.length, 3)
			assertEqual(a.distinct().length, 2)
		})

	Bling.prototype.zip
		.test(function() { assertEqual(new Bling(["one", "two", "three"]).zip('length').join(" "), "3 3 5"); })
	
	Bling.prototype.zip
			.test(function() {
				assertEqual(new Bling([{a:0}, {a:1}, {a:2}]).zap('a', 3).zip('a').join(" "), "3 3 3")
			})

	Bling.prototype.take
			.test(function() {
				var c = new Bling([1,2,3,4,5]).take(3);
				assertEqual(c.length, 3);
				assertEqual(c[3], undefined);
			})

	Bling.prototype.skip
			.test(function() {
				var b = new Bling([1,2,3,4,5]).skip(2);
				assertEqual(b.length, 3);
				assertEqual(b[0], 3);
				assertEqual(b[2], 5);
				assertEqual(b[3], undefined);
			})

	Bling.prototype.last
			.test(function() {
				var b = new Bling([1,2,3,4,5]);
				assertEqual(b.last(), 5);
				var c = b.last(2);
				assertEqual(c.length, 2);
				assertEqual(c[0], 4);
				assertEqual(c[1], 5);
			})
	
	Bling.prototype.first
			.test(function() {
				var b = new Bling([1,2,3,4,5]);
				assertEqual(b.first(), 1);
				assertEqual(b.first(2).join(", "), "1, 2");
			})
	
	Bling.prototype.join
			.test(function() { assertEqual(new Bling([1,2,3,4,5]).join(", "), "1, 2, 3, 4, 5") } )

	Bling.prototype.slice
		.test(function() {
			var b = new Bling([1,2,3,4,5,6,7,8]);
			assertEqual(b.slice(2,4).join(""), "34");
			assertEqual(b.slice(4,6).join(""), "56");
		})
	
	Bling.prototype.concat
		.test(function(){ assertEqual(new Bling([1,2,3]).concat(new Bling([4,5,6])).join(""), "123456") })
	
	Bling.prototype.weave
		.test(function() {
			assertEqual(new Bling([1,2,3]).weave(new Bling(["a","b","c"])).join(""), "a1b2c3")
		})
	
	Bling.prototype.toString
		.test(function() { assertEqual(new Bling([1,2,3,4,5]).toString(), "[1, 2, 3, 4, 5]") })
		.test(function() { assertEqual(new Bling(["a","b"]).toString(), '["a", "b"]') })

	Bling.prototype.floats
		.test(function() { assertEqual(new Bling([1, "3.5", "200px"]).floats().join(", "), "1, 3.5, 200"); })

	Bling.prototype.ints
		.test(function() { assertEqual(new Bling([1, "3.5", "200px"]).ints().join(", "), "1, 3, 200"); })

	Bling.prototype.squares
		.test(function() { assertEqual(new Bling([1, 2, 3]).squares().join(", "), "1, 4, 9"); })

	Bling.prototype.sum
		.test(function() { assertEqual(new Bling([1, 2, 3, 4]).sum(), 10); })

	Bling.prototype.max
		.test(function() { assertEqual(new Bling([1, 2, 3, 4]).max(), 4); })

	Bling.prototype.min
		.test(function() { assertEqual(new Bling([1, 2, 3, 4]).min(), 1); })

	Bling.prototype.average
		.test(function() { assertEqual(new Bling([1, 2, 3, 4]).average(), 2.5); })

	Bling.prototype.magnitude
		.test(function() { assertEqual(new Bling([1, 2, 3]).magnitude(), Math.sqrt(14)); })

	Bling.prototype.scale
		.test(function() { assertEqual(new Bling([1, 2, 3]).scale(2).join(", "), "2, 4, 6") })

	Bling.prototype.call
		.test(function() { assertEqual(new Bling(["a","b","c"]).zip('toUpperCase').call().join(""), "ABC") })
		.test(function() { assertEqual(new Bling(["a","b","c"]).zip('concat').call(".").join(""), "a.b.c.") })

	Bling.prototype.future
		.test(function() {
			var b = new Bling([1,2,3,4,5])
				// spawn a future chain, pointed at b's current state
				.future(0, function() {
					// in the future, we will see the old b
					assertEqual(this.length, 5);
				})
				// back in the past, modify b
				.last(2);
			// and before the future, verify that our local b has changed
			assertEqual(b.length, 2);
		})

	Bling.prototype.merge
		.test(function() {
			assertEqual(new Bling([ new Bling("<div>"), new Bling("<p>") ]).merge().zip('nodeName').join(" "), "DIV P")
		})

	Bling.rgb
		.test(function() { assert(isBling(this("#aaa"))) })
		.test(function() { assertEqual(this("#aaa").rgb(), "rgb(170, 170, 170)") })
	
	Bling.prototype.html
		.test(function() {
			var h = '<p class="foo">This is a paragraph.</p>';
			var b = new Bling("<div>"+h+"</div>");
			assertEqual(b.html().first(), h);
		})

	Bling.prototype.append
		.test(function() { assertEqual(new Bling("<div></div>").append(new Bling("<p>")).child(0).zip('nodeName').join(" "), "P") })
		.test(function() { assertEqual(new Bling("<div></div>").append("<p>").child(0).zip('nodeName').join(" "), "P") })

	Bling.prototype.appendTo
		.test(function() { assertEqual(new Bling("<p>").appendTo(new Bling("<div id='a'></div>")).zip('parentNode.id').join(" "), "a") })
	
	Bling.prototype.text
		.test(function() {
			var h = "<p class='foo'>This is a paragraph.</p>";
			var b = new Bling("<div>"+h+"</div>");
			assertEqual(b.text().first(), "This is a paragraph.");
		})

	Bling.prototype.val
		.test(function() {
			var b = new Bling("<input value='1'><input value='2'><select><option>3</option><option>4</option></select>");
			assertEqual(b.val().join(", "), "1, 2, 3");
		})

	Bling.prototype.css
		.test(function() {
			new Bling("<div style='background-color:transparent;' />")
				.appendTo("body")
				.future(20, function() { assertEqual(this.css('background-color').first(), 'rgba(0, 0, 0, 0)') })
				.future(40, function() { assertEqual(this.css('background-color', "#ffffff").css("background-color").first(), "rgb(255, 255, 255)") })
				.future(60, function() { this.remove() })
		})

	Bling.prototype.rgb
		.test(function() { assertEqual(Bling.rgb("#343434").scale(2).rgb(), "rgb(104, 104, 104)") })
		.test(function() { assertEqual(new Bling([1, 2, 3]).rgb(), "rgb(1, 2, 3)") })
		.test(function() { assertEqual(new Bling([1, 2, 3, .5]).rgb(), "rgba(1, 2, 3, 0.5)") })
		.test(function() { assertEqual(new Bling(["foo"]).rgb(), undefined) })
	
	Bling.prototype.child
		.test(function() {
			var d = new Bling("<div><p><span>here.</span></p></div>");
			assertEqual(d.child(0).zip('nodeName').join(", "), "P");
			assertEqual(d.child(0).child(0).zip('nodeName').join(", "), "SPAN");
		})
	
	Bling.prototype.parent
		.test(function() {
			var d = new Bling("<div><p><span>here.</span></p></div>");
			assertEqual(d.parent().first(), null);
			assertEqual(d.child(0).parent().first().nodeName, "DIV");
		})

	Bling.prototype.parents
		.test(function() {
			assert(isBling(new Bling("<div><p><span>here</span></p></div>").find("span").parents().first()))
		})
		.test(function() {
			assertEqual(
				new Bling("span", new Bling("<div><p><span>here.</span></p></div>"))
					.parents().first()
					.zip('nodeName')
					.join(", "),
				"P, DIV");
		})

	Bling.prototype.remove
		.test(function() { assertEqual(new Bling("<p>").appendTo("<div>").remove().zip('parentNode').first(), null) })

	Bling.prototype.find
		.test(function(){ assertEqual(new Bling("<div><p><span id='a'>text</span></div>").find("span").zip('id').join(" "), "a") })
	
	Bling.duration
		.test(function() {
			assertEqual( this("slow"), 700 );
			assertEqual( this("fast"), 100 );
			assertEqual( this(1000), 1000 );
		})

	Bling.db
		.test(function() { assert( isType( Bling.db()[0], "Database" ) ) })

	Bling.prototype.transaction
		.test(function() {
			Bling.db()
				.transaction(function(t) { 
					t.executeSql("create temp table foo ( id int primary key not null );") 
				}, [], function(t, r) {
					console.log("create table",t, r)
				})
		})
		.test(function() {
			Bling.db()
				.transaction(function(t) {
					t.executeSql("insert into foo (id) values (?);")
				}, [42], function(t, r) {
					console.log("insert",t,r)
				})
		})
		.test(function() {
			Bling.db()
				.transaction(function(t) {
					t.executeSql("select id from foo;")
				}, [], function(t, r) {
					console.log("select",t, r)
				})
		})
		.test(function() {
			Bling.db()
				.transaction(function(t) {
					t.executeSql("drop table foo;")
				}, [], function(t, r) {
					console.log("drop",t, r)
				})
		})

	// schedule the tests to run and clean themselves up
	new Bling(window).bind('load', runAllTests)

})()

