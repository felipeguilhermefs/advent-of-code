local function sum(arr)
	local total = 0
	for _, count in pairs(arr) do
		total = total + count
	end
	return total
end

-- ASCII
local START = 83
local SPLIT = 94

local function countBeams(line, prevBeams)
	local splits = 0
	local currentBeams = {}
	for i = 1, #line do
		if prevBeams == nil then
			-- Initialize the beam count

			if line:byte(i) == START then
				currentBeams[i] = 1
			else
				currentBeams[i] = 0
			end
		else
			-- Propagate or split beams

			local count = prevBeams[i]

			if line:byte(i) ~= SPLIT then
				-- if not a split, just propagate
				currentBeams[i] = count + (currentBeams[i] or 0)
			else
				if count > 0 then
					-- count only if there was a beam above
					splits = splits + 1
				end

				-- if split, then there is no beam here
				currentBeams[i] = 0

				-- beam count is accumulated on both directions
				currentBeams[i - 1] = count + currentBeams[i - 1]
				currentBeams[i + 1] = count + (currentBeams[i + 1] or 0)
			end
		end
	end

	return splits, currentBeams
end

return function(filepath)
	local splits = 0
	local beams = nil

	for line in io.lines(filepath) do
		local newSplits, currentBeams = countBeams(line, beams)
		splits = splits + newSplits
		beams = currentBeams
	end

	return splits, sum(beams)
end
