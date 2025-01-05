local Matrix = require("matrix")

local function isXMAS(map, cell, dir)
	-- try out the letters in sequence in a given direction
	local row = cell.row
	local col = cell.col
	local mas = { "M", "A", "S" }
	for _, letter in pairs(mas) do
		row = row + dir.row
		col = col + dir.col

		if map:get(row, col) ~= letter then
			return false
		end
	end
	return true
end

local function countXMAS(map)
	-- find X and then try MAS in every direction
	local directions = { Matrix.N, Matrix.NE, Matrix.NW, Matrix.W, Matrix.E, Matrix.S, Matrix.SE, Matrix.SW }
	local sum = 0

	for _, cell in pairs(map) do
		if cell.value ~= "X" then
			goto continue
		end

		for _, dir in pairs(directions) do
			if isXMAS(map, cell, dir) then
				sum = sum + 1
			end
		end
		::continue::
	end

	return sum
end

local function isCrossMAS(map, cell, dir)
	-- look for M in a given position, and S in the cross opposite end
	local ms = { ["M"] = 1, ["S"] = -1 }
	for letter, axis in pairs(ms) do
		local lRow = cell.row + dir.row * axis
		local lCol = cell.col + dir.col * axis
		if map:get(lRow, lCol) ~= letter then
			return false
		end
	end

	return true
end

local function countCrossMAS(map)
	-- try out diagonal positions for the X
	local directions = { Matrix.NE, Matrix.NW, Matrix.SE, Matrix.SW }
	local sum = 0

	for _, cell in pairs(map) do
		if cell.value ~= "A" then
			goto continue
		end

		local countDir = 0
		for _, dir in pairs(directions) do
			if isCrossMAS(map, cell, dir) then
				countDir = countDir + 1
			end
		end

		-- should have 2 diagonals to have an X
		if countDir == 2 then
			sum = sum + 1
		end
		::continue::
	end

	return sum
end

return function(filepath)
	local map = Matrix.fromFile(filepath)
	return countXMAS(map), countCrossMAS(map)
end
