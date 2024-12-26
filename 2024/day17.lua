local function Computer(a, b, c)
	local cpt = { a = a, b = b, c = c, p = 1 }

	cpt.combo = {
		[0] = function()
			return 0
		end,
		[1] = function()
			return 1
		end,
		[2] = function()
			return 2
		end,
		[3] = function()
			return 3
		end,
		[4] = function()
			return cpt.a
		end,
		[5] = function()
			return cpt.b
		end,
		[6] = function()
			return cpt.c
		end,
		[7] = function() end,
	}

	cpt.adv = function(op)
		local combo = assert(cpt.combo[op](), "no combo adv")
		cpt.a = math.floor(cpt.a / math.pow(2, combo))
		return true
	end

	cpt.bxl = function(op)
		cpt.b = cpt.b ~ op
		return true
	end

	cpt.bst = function(op)
		local combo = assert(cpt.combo[op](), "no combo bst")
		cpt.b = combo % 8
		return true
	end

	cpt.jnz = function(op)
		if cpt.a == 0 then
			return true
		end

		cpt.p = op + 1
		return false
	end

	cpt.bxc = function()
		cpt.b = cpt.b ~ cpt.c
		return true
	end

	cpt.out = function(op, output)
		local combo = assert(cpt.combo[op](), "no combo out")
		table.insert(output, combo % 8)
		return true
	end

	cpt.bdv = function(op)
		local combo = assert(cpt.combo[op](), "no combo adv")
		cpt.b = math.floor(cpt.a / math.pow(2, combo))
		return true
	end

	cpt.cdv = function(op)
		local combo = assert(cpt.combo[op](), "no combo adv")
		cpt.c = math.floor(cpt.a / math.pow(2, combo))
		return true
	end

	cpt.func = {
		[0] = cpt.adv,
		[1] = cpt.bxl,
		[2] = cpt.bst,
		[3] = cpt.jnz,
		[4] = cpt.bxc,
		[5] = cpt.out,
		[6] = cpt.bdv,
		[7] = cpt.cdv,
	}

	cpt.compute = function(ops)
		local output = {}

		while cpt.p < #ops do
			local opcode = ops[cpt.p]
			local operand = ops[cpt.p + 1]
			local fn = cpt.func[opcode]
			if fn(operand, output) then
				cpt.p = cpt.p + 2
			end
		end

		return table.concat(output, ",")
	end

	return cpt
end

local function readInput(filepath)
	local ops = {}
	local a, b, c
	for line in io.lines(filepath) do
		if line:match("A:") then
			a = tonumber(line:match("%d+"))
		elseif line:match("B:") then
			b = tonumber(line:match("%d+"))
		elseif line:match("C:") then
			c = tonumber(line:match("%d+"))
		elseif line:match("Program") then
			for op in line:gmatch("%d") do
				table.insert(ops, tonumber(op))
			end
		end
	end
	return ops, a, b, c
end

local function quine(ops, b, c)
	local a = 0
	for i = #ops, 1, -1 do
		-- every 3 bits is responsible for one of the outputs
		a = a << 3
		while table.concat(ops, ",", i) ~= Computer(a, b, c).compute(ops) do
			a = a + 1
		end
	end
	return a
end

return function(filepath)
	local ops, a, b, c = readInput(filepath)
	local computer = Computer(a, b, c)
	return computer.compute(ops), quine(ops, b, c)
end
