local Array = require("ff.collections.array")

local function parseReports()
	local reports = Array.new()
	for line in io.lines(arg[1]) do
		local report = Array.new()
		for level in line:gmatch("%d+") do
			report:insert(level)
		end
		reports:insert(report)
	end
	return reports
end

local function isSafe(report)
	local cur = nil
	local asc = nil
	for _, level in pairs(report) do
		if cur ~= nil then
			local diff = level - cur

			if asc == nil then
				asc = diff > 0
			end

			if asc and not (diff >= 1 and diff <= 3) then
				return false
			end
			if not asc and not (diff <= -1 and diff >= -3) then
				return false
			end
		end
		cur = level
	end
	return true
end

local function part1(reports)
	local count = 0
	for _, report in pairs(reports) do
		if isSafe(report) then
			count = count + 1
		end
	end
	return count
end

local function part2(reports)
	local count = 0
	for _, report in pairs(reports) do
		if isSafe(report) then
			count = count + 1
		else
			-- Try skipping each index (very inefficient)
			for i = 1, #report do
				local skipped = Array.new(report)
				skipped:remove(i)
				if isSafe(skipped) then
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
