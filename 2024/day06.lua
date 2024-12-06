-- Read input file into a grid
local GRID = {}
for line in io.lines(arg[1]) do
	local row = {}
	for tile in line:gmatch(".") do
		table.insert(row, tile)
	end
	table.insert(GRID, row)
end

-- Grid directions
local N = { -1, 0 }
local E = { 0, 1 }
local S = { 1, 0 }
local W = { 0, -1 }

N.next = E
E.next = S
S.next = W
W.next = N

local DIR = {
	["^"] = N,
	[">"] = E,
	["v"] = S,
	["<"] = W,
}

local function inGrid(row, col)
	if row < 1 or row > #GRID then
		return false
	end

	if col < 1 or col > #GRID[row] then
		return false
	end

	return true
end

local function findInitialPos()
	local dir
	for row, _ in pairs(GRID) do
		for col, pos in pairs(GRID[row]) do
			dir = DIR[pos]
			if dir then
				return { row = row, col = col, dir = dir }
			end
		end
	end
	return nil
end

local function part1()
	local pos = assert(findInitialPos())

	local totalPos = 1
	while true do
		local nextRow, nextCol = pos.row + pos.dir[1], pos.col + pos.dir[2]
		if not inGrid(nextRow, nextCol) then
			return totalPos
		end

		if GRID[nextRow][nextCol] == "#" then
			pos.dir = pos.dir.next
		end
		if GRID[pos.row][pos.col] ~= "X" then
			GRID[pos.row][pos.col] = "X"
			totalPos = totalPos + 1
		end
		pos.row = pos.row + pos.dir[1]
		pos.col = pos.col + pos.dir[2]
	end
end

print("Part 1", part1())
