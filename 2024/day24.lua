local HashMap = require("ff.collections.hashmap")
local Heap = require("ff.collections.heap")
local Set = require("ff.collections.set")

local function readInput(filepath)
	local wires = HashMap.new()
	local conns = HashMap.new()

	for line in io.lines(filepath) do
		local wire, val = line:match("(%w+): (%d)")
		if wire then
			wires:put(wire, tonumber(val))
			goto continue
		end

		local w1, op, w2, res = line:match("(%w+) (%w+) (%w+) %-> (%w+)")
		if w1 and op and w2 and res then
			conns:put(res, { w1, op, w2 })
		end
		::continue::
	end

	return wires, conns
end

local function value(wires, allWires, wire)
	if wires:contains(wire) then
		return wires:get(wire)
	end

	return allWires:get(wire)
end

local function num(wires)
	local zs = Heap.newMax()
	for wire in pairs(wires) do
		if wire:match("^z") then
			zs:push(wire)
		end
	end

	local number = 0
	while not zs:empty() do
		local z = zs:pop()
		number = (number << 1) + wires:get(z)
	end
	return number
end

local function eval(wires, conns)
	local allWires = HashMap.new()
	local changed = true
	while changed do
		changed = false
		for res, conn in pairs(conns) do
			if allWires:contains(res) then
				goto continue
			end

			local val1 = value(wires, allWires, conn[1])
			local val2 = value(wires, allWires, conn[3])

			if val1 and val2 then
				if conn[2] == "AND" then
					allWires:put(res, val1 & val2)
					changed = true
				elseif conn[2] == "OR" then
					allWires:put(res, val1 | val2)
					changed = true
				elseif conn[2] == "XOR" then
					allWires:put(res, val1 ~ val2)
					changed = true
				end
			end

			::continue::
		end
	end

	return num(allWires)
end

local function id(arr, reverse)
	if reverse then
		return string.format("%s:%s:%s", arr[3], arr[2], arr[1])
	end

	return table.concat(arr, ":")
end

local function mapGates(conns)
	local xors, ands = HashMap.new(), HashMap.new()

	for res, conn in pairs(conns) do
		if conn[2] == "XOR" then
			xors:compute(conn[1], function()
				return HashMap.new()
			end):put(conn[3], res)
			xors:compute(conn[3], function()
				return HashMap.new()
			end):put(conn[1], res)
		elseif conn[2] == "AND" then
			ands:compute(conn[1], function()
				return HashMap.new()
			end):put(conn[3], res)
			ands:compute(conn[3], function()
				return HashMap.new()
			end):put(conn[1], res)
		end
	end

	return xors, ands
end

local function findWrongConns(conns)
	local xors, ands = mapGates(conns)

	local wrong = Set.new()

	for i = 1, 44 do
		local x = string.format("x%02d", i)
		local y = string.format("y%02d", i)
		local z = string.format("z%02d", i)

		local conn = conns:get(z)

		local xor = xors:get(x):get(y)

		if conn[2] ~= "XOR" then
			wrong:add(z)
		end

		local carry = xors:get(xor)
		if carry == nil then
			wrong:add(xor)
			wrong:add(ands:get(x):get(y))
		else
			for xor2 in pairs(carry) do
				if xors:get(xor2):get(xor) ~= z then
					wrong:add(xors:get(xor2):get(xor))
				end
			end
		end
	end

	local gates = {}
	for w in pairs(wrong) do
		table.insert(gates, w)
	end
	table.sort(gates)
	return table.concat(gates, ",")
end

return function(filepath)
	local wires, conns = readInput(filepath)
	return eval(wires, conns), findWrongConns(conns)
end
