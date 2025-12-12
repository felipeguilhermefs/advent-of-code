local function parse(filepath)
	local shapes, regions = {}, {}
	local shapeSize, index = 0, 1
	for line in io.lines(filepath) do
		-- only 6 shapes to parse
		if #shapes < 6 then
			-- blank like marks the end of a shape
			if line == "" then
				shapes[index] = shapeSize
				index = index + 1
				shapeSize = 0
			elseif tonumber(line:match("(%d):")) == nil then
				-- if the line does not start with a number then it is the shape
				for val in line:gmatch(".") do
					-- we want to know the shape size
					if val == "#" then
						shapeSize = shapeSize + 1
					end
				end
			end
		else
			local rows, cols = line:match("(%d+)x(%d+):")

			local countShapes = {}
			for val in line:sub(7):gmatch("(%d+)") do
				table.insert(countShapes, tonumber(val))
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
			required = required + (countShape * shapes[index])
		end

		if available >= required then
			total = total + 1
		end
	end

	return total, 0
end
