local Array = require("ff.collections.array")
local HashMap = require("ff.collections.hashmap")
local Set = require("ff.collections.set")
local Matrix = require("matrix")

local function mirror(a, b)
	return a - (b - a)
end

local function groupAntennas(map)
	local antennas = HashMap.new()
	for _, cell in pairs(map) do
		if not cell.value:match("%w") then
			goto continue
		end

		antennas
			:compute(cell.value, function()
				return Array.new()
			end)
			:insert(cell)

		::continue::
	end

	return antennas
end

local function newAntinode(a, b)
	return Matrix.Cell(mirror(a.row, b.row), mirror(a.col, b.col))
end

local function add(antinodes, toAdd)
	for _, antinode in pairs(toAdd) do
		local key = string.format("%d:%d", antinode.row, antinode.col)
		antinodes:add(key)
	end
end

local function genAntinodes(map, a, b, frequency)
	local antinodes = Array.new()

	local antinodeA = newAntinode(a, b)
	if map:get(antinodeA.row, antinodeA.col) and map:get(antinodeA.row, antinodeA.col) ~= frequency then
		antinodes:insert(antinodeA)
	end

	local antinodeB = newAntinode(b, a)
	if map:contains(antinodeB.row, antinodeB.col) and map:get(antinodeB.row, antinodeB.col) ~= frequency then
		antinodes:insert(antinodeB)
	end

	return antinodes
end

local function resonate(map, antinodes, a, b)
	local antinode = newAntinode(a, b)
	while map:contains(antinode.row, antinode.col) do
		antinodes:insert(antinode)

		b = a
		a = antinode

		antinode = newAntinode(a, b)
	end
end

local function genAntinodesWithResonance(map, a, b)
	local antinodes = Array.new({ a, b })

	resonate(map, antinodes, a, b)
	resonate(map, antinodes, b, a)

	return antinodes
end

return function(filepath)
	local map = Matrix.fromFile(filepath)
	local frequencies = groupAntennas(map)

	local antinodes = Set.new()
	local antinodesWithResonance = Set.new()
	for frequency, antennas in pairs(frequencies) do
		for i = 1, #antennas do
			for j = i + 1, #antennas do
				local a = antennas:get(i)
				local b = antennas:get(j)

				add(antinodes, genAntinodes(map, a, b, frequency))
				add(antinodesWithResonance, genAntinodesWithResonance(map, a, b))
			end
		end
	end

	return #antinodes, #antinodesWithResonance
end
