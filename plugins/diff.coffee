$.plugin
	depends: "inherit,reduce"
	provides: "diff,stringDistance,stringDiff"
, ->
	lev_memo = Object.create null
	min = Math.min
	lev = (s,i,n,t,j,m,dw,iw,sw) ->
		# distance is symmetric so we cache under two keys at once
		return lev_memo[[s,i,n,t,j,m,dw,iw,sw]] ?= lev_memo[[t,j,m,s,i,n,dw,iw,sw]] ?= do -> switch
			when m <= 0 then n
			when n <= 0 then m
			else min(
				dw + lev(s,i+1,n-1, t,j,m,dw,iw,sw),
				iw + lev(s,i,n, t,j+1,m-1,dw,iw,sw),
				(sw * (s[i] isnt t[j])) + lev(s,i+1,n-1, t,j+1,m-1,dw,iw,sw)
			)

	collapse = (ops) -> # combines similar operations in a sequence
		$.inherit {
			toHTML: ->
				@reduce(((a,x) ->
					a += switch x.op
						when 'ins' then "<ins>#{x.v}</ins>"
						when 'del' then "<del>#{x.v}</del>"
						when 'sub' then "<del>#{x.v}</del><ins>#{x.w}</ins>"
						when 'sav' then x.v
				), "")
		}, ops.reduce(((a,x) ->
			if x.op is 'sub' and x.v is x.w # replacing with the same thing is just preserving
				x.op = 'sav'
				delete x.w
			unless a.length
				a.push x
			else
				if (last = a.last()).op is x.op
					last.v += x.v
					if last.op is 'sub'
						last.w += x.w
				else
					a.push x
			return a
		), $())


	diff_memo = Object.create null
	del = (c) -> {op:'del',v:c}
	ins = (c) -> {op:'ins',v:c}
	sub = (c,d) -> {op:'sub',v:c,w:d}
	diff = (s,i,n,t,j,m,dw,iw,sw) ->
		# diffs are not symmetric, so only cache under one key
		return diff_memo[[s,i,n,t,j,m,dw,iw,sw]] ?= collapse do -> switch
			when m <= 0 then (del c) for c in s.substr i,n
			when n <= 0 then (ins c) for c in t.substr j,m
			else
				sw *= (s[i] isnt t[j])
				args =
					del: [s+0,i+1,n-1,t+0,j+0,m+0,  1.00,1.50,1.50]
					ins: [s+0,i+0,n+0,t+0,j+1,m-1,  1.50,1.00,1.50]
					sub: [s+0,i+1,n-1,t+0,j+1,m-1,  1.00,1.00,1.00]
				costs =
					del: dw + lev args.del...
					ins: iw + lev args.ins...
					sub: sw + lev args.sub...
				switch min costs.del, costs.ins, costs.sub
					when costs.del then $(del s[i]).concat diff args.del...
					when costs.ins then $(ins t[j]).concat diff args.ins...
					when costs.sub then $(sub s[i],t[j]).concat diff args.sub...

	$:
		stringDistance: (s, t) -> lev s,0,s.length, t,0,t.length,1,1,1
		stringDiff: (s, t) -> diff s,0,s.length, t,0,t.length,1,1,1.5

