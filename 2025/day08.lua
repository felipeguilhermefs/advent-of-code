local Comparator = require("ff.func.comparator")
local Heap = require("ff.collections.heap")
local Set = require("ff.collections.set")

local function parseJunctionBoxes(filepath)
	local jb = {}
	for line in io.lines(filepath) do
		local x, y, z = line:match("(%d+),(%d+),(%d+)")

		table.insert(jb, { x = tonumber(x), y = tonumber(y), z = tonumber(z) })
	end
	return jb
end

local function distance(a, b)
	-- no need to take sqrt for this exercise purposes
	return math.pow(a.x - b.x, 2) + math.pow(a.y - b.y, 2) + math.pow(a.z - b.z, 2)
end

local function calculateDistances(boxes)
	local closest = function(a, b)
		if a.distance > b.distance then
			return Comparator.greater
		end

		if a.distance < b.distance then
			return Comparator.less
		end

		return Comparator.equal
	end

	local distances = Heap.new(closest)

	for i = 1, #boxes do
		for j = i + 1, #boxes do
			distances:push({
				distance = distance(boxes[i], boxes[j]),
				a = i,
				b = j,
			})
		end
	end

	return distances
end

local function initializeCircuits(boxes)
	local circuits = {}
	for i = 1, #boxes do
		local circuit = Set.new()
		circuit:add(i)
		table.insert(circuits, circuit)
	end
	return circuits
end

local function part1(circuits, top)
	local uniq = Set.new() .. circuits

	local largest = function(a, b)
		if #a < #b then
			return Comparator.greater
		end

		if #a > #b then
			return Comparator.less
		end

		return Comparator.equal
	end

	local heap = Heap.new(largest)
	for circuit in pairs(uniq) do
		heap:push(circuit)
	end

	local res = 1
	for _ = 1, top do
		local circuit = heap:pop()
		res = res * #circuit
	end
	return res
end

return function(filepath)
	local boxes = parseJunctionBoxes(filepath)

	local distances = calculateDistances(boxes)
	local circuits = initializeCircuits(boxes)

	local countdown = 1000
	local largest = 0
	while true do
		local pair = distances:pop()

		circuits[pair.a] = circuits[pair.a] .. circuits[pair.b]

		for i in pairs(circuits[pair.b]) do
			circuits[i] = circuits[pair.a]
		end

		if countdown == 1 then
			largest = part1(circuits, 3)
		end

		if #circuits[pair.a] == #boxes then
			local part2 = boxes[pair.a].x * boxes[pair.b].x
			return largest, part2
		end
		countdown = countdown - 1
	end
end
