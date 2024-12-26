local Set = require("ff.collections.set")

local function readInput(filepath)
	local map = {}
	for line in io.lines(filepath) do
		local row = {}
		for tile in line:gmatch(".") do
			table.insert(row, tile)
		end
		table.insert(map, row)
	end
	return map
end

local function inMap(map, antinode)
	if antinode[1] < 1 or antinode[1] > #map then
		return false
	end

	if antinode[2] < 1 or antinode[2] > #map[1] then
		return false
	end

	return true
end

local function mirror(a, b)
	return a - (b - a)
end

local function groupAntennas(map)
	local antennas = {}
	for row, _ in pairs(map) do
		for col, pos in pairs(map[row]) do
			if not pos:match("%w") then
				goto continue
			end

			if antennas[pos] == nil then
				antennas[pos] = {}
			end

			table.insert(antennas[pos], { row, col })

			::continue::
		end
	end

	return antennas
end

local function newAntinode(a, b)
	return { mirror(a[1], b[1]), mirror(a[2], b[2]) }
end

local function add(antinodes, toAdd)
	for _, antinode in pairs(toAdd) do
		local key = string.format("%d:%d", antinode[1], antinode[2])
		antinodes:add(key)
	end
end

local function genAntinodes(map, a, b, frequency)
	local antinodes = {}

	local antinodeA = newAntinode(a, b)
	if inMap(map, antinodeA) and map[antinodeA[1]][antinodeA[2]] ~= frequency then
		table.insert(antinodes, antinodeA)
	end

	local antinodeB = newAntinode(b, a)
	if inMap(map, antinodeB) and map[antinodeB[1]][antinodeB[2]] ~= frequency then
		table.insert(antinodes, antinodeB)
	end

	return antinodes
end

local function resonate(map, antinodes, a, b)
	local antinode = newAntinode(a, b)
	while inMap(map, antinode) do
		table.insert(antinodes, antinode)

		b = a
		a = antinode

		antinode = newAntinode(a, b)
	end
end

local function genAntinodesWithResonance(map, a, b)
	local antinodes = {}
	table.insert(antinodes, a)
	table.insert(antinodes, b)

	resonate(map, antinodes, a, b)
	resonate(map, antinodes, b, a)

	return antinodes
end

return function(filepath)
	local map = readInput(filepath)
	local frequencies = groupAntennas(map)

	local antinodes = Set.new()
	local antinodesWithResonance = Set.new()
	for frequency, antennas in pairs(frequencies) do
		for i = 1, #antennas do
			for j = i + 1, #antennas do
				local a = antennas[i]
				local b = antennas[j]

				add(antinodes, genAntinodes(map, a, b, frequency))
				add(antinodesWithResonance, genAntinodesWithResonance(map, a, b))
			end
		end
	end

	return #antinodes, #antinodesWithResonance
end
