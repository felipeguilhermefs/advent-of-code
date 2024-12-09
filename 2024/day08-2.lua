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

local function addAntinodes(antinodes, a, b)
	while true do
		local antinode = { mirror(a[1], b[1]), mirror(a[2], b[2]) }
		if not inMap(antinode) then
			return
		end

		local key = string.format("%d:%d", antinode[1], antinode[2])
		antinodes[key] = antinode

		b = a
		a = antinode
	end
end
local function accumulate(antinodes, freq, antennas)
	for i = 1, #antennas do
		for j = i + 1, #antennas do
			local a = antennas[i]
			local b = antennas[j]

			local key = string.format("%d:%d", a[1], a[2])
			antinodes[key] = a

			key = string.format("%d:%d", b[1], b[2])
			antinodes[key] = b

			addAntinodes(antinodes, a, b)
			addAntinodes(antinodes, b, a)
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
		-- print(freq, #a)
		accumulate(antinodes, freq, a)
	end

	local count = 0
	for k, _ in pairs(antinodes) do
		-- print(k)
		count = count + 1
	end

	return count
end

print("Part 1", part1(MAP))
