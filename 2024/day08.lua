local function readInput()
	local map = {}
	for line in io.lines(arg[1]) do
		local row = {}
		for tile in line:gmatch(".") do
			table.insert(row, tile)
		end
		table.insert(map, row)
	end
	return map
end

local MAP = readInput()

local function inMap(antinode)
	if antinode[1] < 1 or antinode[1] > #MAP then
		return false
	end

	if antinode[2] < 1 or antinode[2] > #MAP[1] then
		return false
	end

	return true
end

local function mirror(a, b)
	return a - (b - a)
end

local function accumulate(antinodes, freq, antennas)
	for i = 1, #antennas do
		for j = i, #antennas do
			local a = antennas[i]
			local b = antennas[j]

			local antinodeA = { mirror(a[1], b[1]), mirror(a[2], b[2]) }
			if inMap(antinodeA) and MAP[antinodeA[1]][antinodeA[2]] ~= freq then
				local key = string.format("%d:%d", antinodeA[1], antinodeA[2])
				antinodes[key] = antinodeA
			end
			local antinodeB = { mirror(b[1], a[1]), mirror(b[2], a[2]) }
			if inMap(antinodeB) and MAP[antinodeB[1]][antinodeB[2]] ~= freq then
				local key = string.format("%d:%d", antinodeB[1], antinodeB[2])
				antinodes[key] = antinodeB
			end
		end
	end
end

local function part1(map)
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

	local antinodes = {}
	for freq, a in pairs(antennas) do
		accumulate(antinodes, freq, a)
	end

	local count = 0
	for k, _ in pairs(antinodes) do
		print(k)
		count = count + 1
	end

	return count
end

print("Part 1", part1(MAP))
