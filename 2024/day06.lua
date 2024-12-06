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

local function copyGrid()
	local grid = {}
	for _, row in pairs(GRID) do
		local newRow = {}
		for _, pos in pairs(row) do
			table.insert(newRow, pos)
		end
		table.insert(grid, newRow)
	end
	return grid
end

local function newGuard(row, col, dir)
	return { row = row, col = col, dir = dir }
end

local function findGuard()
	local dir
	for row, _ in pairs(GRID) do
		for col, pos in pairs(GRID[row]) do
			dir = DIR[pos]
			if dir then
				return newGuard(row, col, dir)
			end
		end
	end
	return nil
end

local function part1()
	local guard = assert(findGuard())
	local grid = copyGrid()

	local positions = 1
	while true do
		local nextRow, nextCol = guard.row + guard.dir[1], guard.col + guard.dir[2]
		if not inGrid(nextRow, nextCol) then
			return positions
		end

		if grid[nextRow][nextCol] == "#" then
			guard.dir = guard.dir.next
		end
		if grid[guard.row][guard.col] ~= "X" then
			grid[guard.row][guard.col] = "X"
			positions = positions + 1
		end
		guard.row = guard.row + guard.dir[1]
		guard.col = guard.col + guard.dir[2]
	end
end

local function isLoop(grid, guard)
	local limit = #grid * #grid[1]
	for _ = 1, limit do
		local nextRow, nextCol = guard.row + guard.dir[1], guard.col + guard.dir[2]
		if not inGrid(nextRow, nextCol) then
			return false
		end

		if grid[nextRow][nextCol] == "#" then
			guard.dir = guard.dir.next
		end
		guard.row = guard.row + guard.dir[1]
		guard.col = guard.col + guard.dir[2]
	end
	return true
end

local function findGuardPath()
	local guard = assert(findGuard())
	local grid = copyGrid()

	local positions = {}
	while true do
		local nextRow, nextCol = guard.row + guard.dir[1], guard.col + guard.dir[2]

		if positions[guard.row] == nil then
			positions[guard.row] = {}
		end
		positions[guard.row][guard.col] = true

		if not inGrid(nextRow, nextCol) then
			return positions
		end

		if grid[nextRow][nextCol] == "#" then
			guard.dir = guard.dir.next
		end
		guard.row = guard.row + guard.dir[1]
		guard.col = guard.col + guard.dir[2]
	end
end

local function part2()
	local guard = assert(findGuard())
	local positions = findGuardPath()
	local count = 0
	for row, _ in pairs(positions) do
		for col, _ in pairs(positions[row]) do
			if row == guard.row and col == guard.col then
				goto continue
			end
			local grid = copyGrid()
			grid[row][col] = "#"
			if isLoop(grid, newGuard(guard.row, guard.col, guard.dir)) then
				count = count + 1
			end
			::continue::
		end
	end
	return count
end

print("Part 1", part1())
print("Part 2", part2())
