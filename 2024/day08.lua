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

local function antinodePos(a, b)
	return mirror(a.row, b.row), mirror(a.col, b.col)
end

local function genAntinodes(map, a, b, frequency)
	local antinodes = Array.new()

	local aRow, aCol = antinodePos(a, b)
	local antinodeA = map:get(aRow, aCol)
	if antinodeA and antinodeA.value ~= frequency then
		antinodes:insert(antinodeA)
	end

	local bRow, bCol = antinodePos(b, a)
	local antinodeB = map:get(bRow, bCol)
	if antinodeB and antinodeB.value ~= frequency then
		antinodes:insert(antinodeB)
	end

	return antinodes
end

local function resonate(map, antinodes, a, b)
	local row, col = antinodePos(a, b)
	local antinode = map:get(row, col)
	while antinode do
		antinodes:insert(antinode)

		b = a
		a = antinode

		row, col = antinodePos(a, b)
		antinode = map:get(row, col)
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

				antinodes = antinodes .. genAntinodes(map, a, b, frequency)
				antinodesWithResonance = antinodesWithResonance .. genAntinodesWithResonance(map, a, b)
			end
		end
	end

	return #antinodes, #antinodesWithResonance
end
