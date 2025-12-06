local function add(a, b)
	return a + b
end

local function mul(a, b)
	return a * b
end

local function reduce(init, arr, fn)
	local acc = init
	for _, val in pairs(arr) do
		acc = fn(acc, val)
	end
	return acc
end

local function part1(filepath)
	local problems = {}

	for line in io.lines(filepath) do
		local column = 1

		if line:match("%d") then
			-- Numbers line
			for op in line:gmatch("%d+") do
				if problems[column] == nil then
					problems[column] = {}
				end

				table.insert(problems[column], tonumber(op))

				column = column + 1
			end
		else
			-- Operators line
			for op in line:gmatch("%p") do
				if op == "+" then
					problems[column] = reduce(0, problems[column], add)
				else
					problems[column] = reduce(1, problems[column], mul)
				end

				column = column + 1
			end
		end
	end

	return reduce(0, problems, add)
end

local ASCII_SPACE = 32
local ASCII_PLUS = 43
local ASCII_ZERO = 48

local function part2(filepath)
	local grid = {}
	for line in io.lines(filepath) do
		table.insert(grid, line)
	end

	-- Identify separator columns
	local separators = {}
	for col = 1, #grid[1] do
		local separator = true
		for _, row in pairs(grid) do
			if row:byte(col) ~= ASCII_SPACE then
				separator = false
				break
			end
		end
		separators[col] = separator
	end

	-- Group columns into problem blocks
	local blocks = {}
	local cur = {}

	for col = 1, #grid[1] do
		if not separators[col] then
			table.insert(cur, col)
		else
			if #cur > 0 then
				table.insert(blocks, cur)
				cur = {}
			end
		end
	end
	if #cur > 0 then
		table.insert(blocks, cur)
	end

	local total = 0

	for _, block in pairs(blocks) do
		local values = {}
		local operator = nil

		for _, col in pairs(block) do
			local num = 0

			for i, row in pairs(grid) do
				local char = row:byte(col)

				if char == ASCII_SPACE then
					goto continue
				end

				if i == #grid then
					operator = char
				else
					num = 10 * num + (char - ASCII_ZERO)
				end
				::continue::
			end

			table.insert(values, num)
		end

		if operator == ASCII_PLUS then
			total = total + reduce(0, values, add)
		else
			total = total + reduce(1, values, mul)
		end
	end

	return total
end

return function(filepath)
	return part1(filepath), part2(filepath)
end
