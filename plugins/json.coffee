$.plugin
	provides: "toHTML"
	depends: "type,synth,once"
, ->
	dumpStyles = $.once -> try $("head").append $.synth("style#dump").text """
		table.dump                { border: 1px solid black; }
		table.dump tr.h           { background-color: blue; color: white; cursor: pointer; }
		table.dump tr.h th        { padding: 0px 4px; }
		table.dump tr.h.array     { background-color: purple; }
		table.dump tr.h.bling     { background-color: gold; }
		table.dump td             { padding: 2px; }
		table.dump td.k           { background-color: lightblue; }
		table.dump td.v.string    { background-color: #cfc; }
		table.dump td.v.number    { background-color: #ffc; }
		table.dump td.v.bool      { background-color: #fcf; }
	"""
	dumpScript = $.once -> try $("head").append $.synth("script#dump").text """
		$(document.body).delegate('table.dump tr.h', 'click', function() {
			$(this.parentNode).find("tr.kv").toggle()
		})
	"""

	table = (t, rows) ->
		tab = $.synth "table.dump tr.h.#{t} th[colspan=2] '#{t}'"
		if t in ["array","bling","nodelist"]
			tab.find("th").appendText " [#{rows.length}]"
		tab.append(row) for row in rows
		tab[0]
	tableRow = (k, v, open) ->
		row = $.synth "tr.kv td.k[align=right][valign=top] '#{k}' + td.v"
		td = row.find "td.v"
		switch _t = $.type v = $.toHTML v, open
			when "string","number","bool","html","null","undefined" then td.appendText String v
			else td.append v
		td.addClass _t
		row.toggle() unless open
		return row

	return { $: {
		toHTML: (obj, open=true) ->
			do dumpStyles
			do dumpScript
			return switch t = $.type obj
				when "string","number","bool","null","undefined","html" then obj
				when "bling","array","nodelist"
					table(t, tableRow(k, v, open) for v,k in obj)
				when "object","array"
					table(t, tableRow(k, v, open) for k,v of obj)
				when "node"
					s = $.HTML.stringify obj
					s.substr(0, s.indexOf('>') + 1) + '...'
				else String(obj)
	} }
