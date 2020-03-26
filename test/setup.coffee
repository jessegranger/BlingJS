
dom = require('jldom')
dom.registerGlobals(global)
global.document = dom.createDocument()
global.window = global
window.innerWidth = 1234
window.innerHeight = 321
# set up a test document, to run DOM tests against
document.body.innerHTML = """
	<table>
		<tr><td>1,1</td><td>1,2</td></tr>
		<tr><td>2,1</td><td>2,2</td></tr>
		<tr><td>3,1</td><td class='d'>3,2</td></tr>
		<tr><td>4,1</td><td>4,2</td></tr>
	</table>
	<div class='c'>C</div>
	<p><span>foobar</span></p>
	<div id='empty'></div>
"""

global.reporter = global.defaultReporter = {
}

global.reporter = {
	default: (g, c, result) -> console.log "#{g} :: #{c} - #{result}"
	minimal: (g, c, result) ->
		process.stdout.write switch true
			when result is passToken then "."
			when "--bail" in process.argv then result
			else "X"
}
global.reporter.current = global.reporter.default;
if "--minimal" in process.argv
	global.reporter.current = global.reporter.minimal;

clear = -> console.log '\x1b[2J'

global.describe = (groupName, func) ->
	promises = []
	global.it = (c,t) ->
		promises.push itPromise(c, t).then (r) ->
			global.reporter.current(groupName,c,r)
			if r isnt passToken and "--bail" in process.argv
				console.log(r)
				process.exit(1)
	func()
	await Promise.all(promises)

passToken = "Pass"
itPromise = (caseName, testFunc) -> new Promise (resolve, reject) ->
	try switch true
		when not testFunc? then resolve(passToken)
		when testFunc.length > 0 then testFunc (err) -> resolve err ? passToken
		else
			testFunc()
			resolve(passToken)
	catch err
		resolve(err)

describe "Test Harness", ->
	it "works", (ok) -> ok()

module.exports = [
	'../dist/bling.js',
	'assert'
].map require
