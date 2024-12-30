local Matrix = require("matrix")

local N = { -1, 0 }
local NE = { -1, 1 }
local E = { 0, 1 }
local SE = { 1, 1 }
local S = { 1, 0 }
local SW = { 1, -1 }
local W = { 0, -1 }
local NW = { -1, -1 }

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

local function isXMAS(map, row, col, dir)
	-- try out the letters in sequence in a given direction
	local mas = { "M", "A", "S" }
	for _, letter in pairs(mas) do
		row = row + dir[1]
		col = col + dir[2]

		if not Matrix.contains(map, row, col) then
			return false
		end

		if map[row][col] ~= letter then
			return false
		end
	end
	return true
end

local function countXMAS(map)
	-- find X and then try MAS in every direction
	local directions = { N, NE, NW, W, E, S, SE, SW }
	local sum = 0

	for row, _ in pairs(map) do
		for col, letter in pairs(map[row]) do
			if letter ~= "X" then
				goto continue
			end

			for _, dir in pairs(directions) do
				if isXMAS(map, row, col, dir) then
					sum = sum + 1
				end
			end
			::continue::
		end
	end

	return sum
end

local function isCrossMAS(map, row, col, dir)
	-- look for M in a given position, and S in the cross opposite end
	local ms = { ["M"] = 1, ["S"] = -1 }
	for letter, axis in pairs(ms) do
		local lRow = row + dir[1] * axis
		local lCol = col + dir[2] * axis
		if not Matrix.contains(map, lRow, lCol) then
			return false
		end

		if map[lRow][lCol] ~= letter then
			return false
		end
	end

	return true
end

local function countCrossMAS(map)
	-- try out diagonal positions for the X
	local directions = { NE, NW, SE, SW }
	local sum = 0

	for row, _ in pairs(map) do
		for col, letter in pairs(map[row]) do
			if letter ~= "A" then
				goto continue
			end

			local countDir = 0
			for _, dir in pairs(directions) do
				if isCrossMAS(map, row, col, dir) then
					countDir = countDir + 1
				end
			end

			-- should have 2 diagonals to have an X
			if countDir == 2 then
				sum = sum + 1
			end
			::continue::
		end
	end

	return sum
end

return function(filepath)
	local map = readInput(filepath)
	return countXMAS(map), countCrossMAS(map)
end
