local HashMap = require("ff.collections.hashmap")
local Heap = require("ff.collections.heap")

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

return function(filepath)
	local wires, conns = readInput(filepath)
	return eval(wires, conns), 0
end
