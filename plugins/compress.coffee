
$.plugin {
	provides: "compress, decompress"
}, ->
	# LZ-based compression algorithm
	# Based on code by Pieroxy <pieroxy@pieroxy.net>, License: WTFPL

	f = String.fromCharCode
	chr = (i) -> f(i+32)
	{ pow } = Math

	_compress = (input) ->
		if input in [null,undefined,""]
			return input
		dict         = {}
		dictToCreate = {}
		c            = ""
		wc           = ""
		w            = ""
		enlargeIn    = 2 # Compensate for the first entry which should not count
		dictSize     = 3
		numBits      = 2
		data         = []
		data_val     = 0
		data_pos     = 0

		doSomeBits = (how_many_bits, value=0) ->
			for i in [0...numBits] by 1
				data_val = (data_val << 1) | value
				if data_pos == 14
					data_pos = 0
					data.push chr data_val
					data_val = 0
				else
					data_pos++
				value = 0
			value = w.charCodeAt(0);
			doBitsAndOne(how_many_bits, value)
		
		doBitsAndOne = (how_many_bits, value=0) ->
			for i in [0...how_many_bits] by 1
				data_val = (data_val << 1) | (value&1)
				if data_pos == 14
					data_pos = 0;
					data.push(chr(data_val));
					data_val = 0;
				else
					data_pos++
				value = value >> 1

		for c in input
			unless c of dict
				dict[c] = dictSize++
				dictToCreate[c] = true;

			wc = w + c
			if wc of dict
				w = wc
			else
				if w of dictToCreate
					if w.charCodeAt(0)<256
						doSomeBits(8)
					else
						doSomeBits(16, 1)
					enlargeIn--
					if enlargeIn == 0
						enlargeIn = pow 2, numBits
						numBits++
					delete dictToCreate[w]
				else
					value = dict[w];
					doBitsAndOne(numBits, value)
				enlargeIn--
				if enlargeIn == 0
					enlargeIn = pow(2, numBits);
					numBits++;
				# Add wc to the dict.
				dict[wc] = dictSize++
				w = String c

		# Output the code for w.
		if w isnt ""
			if w of dictToCreate
				if w.charCodeAt(0)<256
					doSomeBits(8)
				else
					doSomeBits(16,1)
				enlargeIn--;
				if enlargeIn == 0
					enlargeIn = pow 2, numBits
					numBits++
				delete dictToCreate[w]
			else
				value = dict[w]
				doBitsAndOne(numBits, value)
			enlargeIn--
			if enlargeIn == 0
				enlargeIn = pow 2, numBits
				numBits++

		# Mark the end of the stream
		doBitsAndOne(numBits, 2)

		# Flush the last char
		while true
			data_val = (data_val << 1)
			if data_pos == 14
				data.push chr data_val
				break
			else data_pos++
		return data.join('');

	_decompress = (length, resetValue, getNextValue) ->
		return "" if length is 0
		dict = []
		enlargeIn = 4
		dictSize = 4
		numBits = 3
		entry = ""
		result = []
		next = i = w = resb = c = null
		data = {val:getNextValue(0), position:resetValue, index:1}

		if isNaN(data.val) or not isFinite(data.val) or not data.val?
			return ""

		dict[0] = 0
		dict[1] = 1
		dict[2] = 2

		doBits = (bits, maxpower, power=1) ->
			while power isnt maxpower
				resb = data.val & data.position
				data.position >>= 1
				if data.position == 0
					data.position = resetValue
					data.val = getNextValue(data.index++)
				r = if resb > 0 then 1 else 0
				bits |= r * power;
				power <<= 1;
			bits
		
		bits = doBits(0,4,1)

		switch next = bits
			when 0,1
				c = f doBits(0, pow(2,8*(c+1)),1)
			when 2
				return ""
		dict[3] = c
		w = c
		result.push(c)
		while true
			if data.index > length
				return "";

			switch c = doBits(0, pow(2,numBits), 1)
				when 0,1
					dict[dictSize++] = f doBits(0, pow(2,8*(c+1)), 1)
					c = dictSize-1
					enlargeIn--
				when 2
					return result.join('');

			if enlargeIn == 0
				enlargeIn = pow(2, numBits)
				numBits++

			if dict[c]
				entry = dict[c]
			else
				if c == dictSize
					entry = w + w.charAt(0)
				else
					return "";
			result.push(entry)

			# Add w+entry[0] to the dict.
			dict[dictSize++] = w + entry.charAt(0)
			enlargeIn--

			w = entry

			if enlargeIn == 0
				enlargeIn = pow(2, numBits)
				numBits++

	return {
		$:
			compress: (input) ->
				if input then return _compress(input, 15) + " ";
				else return ""
			decompress: (input) ->
				if input then return _decompress input.length, 16384, (i) -> input.charCodeAt(i) - 32
				else return ""
	}


