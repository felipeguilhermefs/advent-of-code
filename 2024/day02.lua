local Array = require("ff.collections.array")

local function readInput(filepath)
	local reports = Array.new()
	for line in io.lines(filepath) do
		local report = Array.new()
		for level in line:gmatch("%d+") do
			report:insert(level)
		end
		reports:insert(report)
	end
	return reports
end

local function isSafe(report, skip)
	local cur = nil
	local asc = nil
	for index, level in pairs(report) do
		if index == skip then
			goto continue
		end
		if cur ~= nil then
			local diff = level - cur

			if asc == nil then
				asc = diff > 0
			end

			if asc and not (diff >= 1 and diff <= 3) then
				return false, index
			end
			if not asc and not (diff <= -1 and diff >= -3) then
				return false, index
			end
		end
		cur = level

	    ::continue::
	end
	return true, nil
end

local function part1(reports)
	local count = 0
	for _, report in pairs(reports) do
		local safe, _ = isSafe(report)
		if safe then
			count = count + 1
		end
	end
	return count
end

local function part2(reports)
	local count = 0
	for _, report in pairs(reports) do
		local safe, errorIndex = isSafe(report)
		if safe then
			count = count + 1
		else
			for i=errorIndex-1, errorIndex do
				safe, _ = isSafe(report, i)
				if safe then
					count = count + 1
					break
				end
			end
		end
	end
	return count
end

return function (filepath)
	local reports = readInput(filepath)

	return part1(reports), part2(reports)
end
