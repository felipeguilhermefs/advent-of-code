local Set = require("ff.collections.set")

local N = { -1, 0 }
local E = { 0, 1 }
local S = { 1, 0 }
local W = { 0, -1 }

local DIRECTIONS = { N, E, S, W }

local function readInput()
	local map = {}
	for line in io.lines(arg[1]) do
		local row = {}
		for height in line:gmatch("%d") do
			row[#row + 1] = tonumber(height)
		end
		map[#map + 1] = row
	end
	return map
end

local function inMap(map, row, col)
	if row < 1 or row > #map then
		return false
	end

	if col < 1 or col > #map[row] then
		return false
	end

	return true
end

local function findPeaks(map, row, col, height, reached)
	reached = reached or Set.new()

	if not inMap(map, row, col) then
		return reached
	end

	if map[row][col] ~= height then
		return reached
	end

	if height == 9 then
		reached:add(string.format("%d:%d", row, col))
		return reached
	end

	for _, dir in pairs(DIRECTIONS) do
		findPeaks(map, row + dir[1], col + dir[2], height + 1, reached)
	end

	return reached
end

local function countTrails(map, row, col, height)
	if not inMap(map, row, col) then
		return 0
	end

	if map[row][col] ~= height then
		return 0
	end

	if height == 9 then
		return 1
	end

	local count = 0
	for _, dir in pairs(DIRECTIONS) do
		count = count + countTrails(map, row + dir[1], col + dir[2], height + 1)
	end
	return count
end

local function run()
	local map = readInput()
	local score = 0
	local nTrails = 0

	for row, _ in pairs(map) do
		for col, height in pairs(map[row]) do
			if height == 0 then
				local reached = findPeaks(map, row, col, height)
				score = score + #reached
				nTrails = nTrails + countTrails(map, row, col, height)
			end
		end
	end

	return score, nTrails
end

local part1, part2 = run()
print("Part 1", part1)
print("Part 2", part2)
