local function parse(filepath)
	local shapes, regions = {}, {}
	local shape, index, row = { format = {}, size = 0 }, 1, 1
	for line in io.lines(filepath) do
		if #shapes < 6 then
			if line == "" then
				shapes[index] = shape
				index = index + 1
				row = 1
				shape = { format = {}, size = 0 }
			elseif tonumber(line:match("(%d):")) == nil then
				for val in line:gmatch(".") do
					if shape.format[row] == nil then
						shape.format[row] = {}
					end

					table.insert(shape.format[row], val)

					if val == "#" then
						shape.size = shape.size + 1
					end
				end

				row = row + 1
			end
		else
			local rows, cols = line:match("(%d+)x(%d+):")
			local countShapes = {}

			for val in line:sub(7):gmatch("(%d+)") do
				table.insert(countShapes, tonumber(val))
			end

			if tonumber(rows) == nil then
				print("HERE:", line)
			end

			local region = { rows = tonumber(rows), cols = tonumber(cols), shapes = countShapes }
			table.insert(regions, region)
		end
	end

	return shapes, regions
end

return function(filepath)
	local shapes, regions = parse(filepath)

	local total = 0
	for _, region in pairs(regions) do
		local available = region.rows * region.cols
		local required = 0
		for index, countShape in pairs(region.shapes) do
			required = required + (countShape * shapes[index].size)
		end

		if available >= required then
			total = total + 1
		end
	end

	return total
end
