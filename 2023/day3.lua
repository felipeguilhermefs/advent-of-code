local function addNumber(grid, row, col, pieces)
	-- Use two pointer to find the number in the row
	local low = col - 1
	local high = col + 1
	local grow = grid[row]
	local run = true
	while run and low >= 1 and high <= #grow do
		run = false
		if grow[low]:match("%d") then
			low = low - 1
			run = true
		end

		if grow[high]:match("%d") then
			high = high + 1
			run = true
		end
	end

	-- Concat the digits
	local piece = {}
	for c = low + 1, high - 1 do
		piece[#piece + 1] = grow[c]
	end

	-- Store the number indexed by row and col, to avoid duplicates
	if not pieces[row] then
		pieces[row] = {}
	end
	pieces[row][low + 1] = tonumber(table.concat(piece, ""))
end

local function addPieces(grid, row, col, pieces)
	-- Look around the symbol for a number to add
	for r = row - 1, row + 1 do
		for c = col - 1, col + 1 do
			if grid[r][c]:match("%d") then
				addNumber(grid, r, c, pieces)
			end
		end
	end
end

local function part1()
	-- Create a grid
	local grid = {}
	for line in io.lines("input3.txt") do
		local row = {}
		for tile in line:gmatch(".") do
			table.insert(row, tile)
		end
		table.insert(grid, row)
	end

	-- Look for symbols that marks pieces to add them
	local pieces = {}
	for r, line in pairs(grid) do
		for c, char in pairs(line) do
			if not char:match("[%d%.]") then
				addPieces(grid, r, c, pieces)
			end
		end
	end

	-- Sum pieces
	local sum = 0
	for _, row in pairs(pieces) do
		for _, piece in pairs(row) do
			sum = sum + piece
		end
	end

	return sum
end

print("Part 1:", part1())
