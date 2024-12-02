local function parseReports()
	local reports = {}
	for line in io.lines(arg[1]) do
		local report = {}
		for level in line:gmatch("%d+") do
			table.insert(report, level)
		end
		table.insert(reports, report)
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

local REPORTS = parseReports()

print("Part 1", part1(REPORTS))
print("Part 2", part2(REPORTS))
