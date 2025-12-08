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

local function countBeams(line, beams)
	local splits = 0
	local first = #beams == 0
	for i = 1, #line do
		if first then
			-- Initialize the beam count

			if line:byte(i) == START then
				beams[i] = 1
			else
				beams[i] = 0
			end
		else
			-- Propagate or split beams

			if line:byte(i) == SPLIT then
				if beams[i] > 0 then
					-- count only if there was a beam above
					splits = splits + 1
				end

				-- beam count is accumulated on both directions
				beams[i - 1] = beams[i] + beams[i - 1]
				beams[i + 1] = beams[i] + beams[i + 1]

				-- if split, then there is no beam here
				beams[i] = 0
			end
		end
	end

	return splits
end

return function(filepath)
	local splits = 0
	local beams = {}

	for line in io.lines(filepath) do
		splits = splits + countBeams(line, beams)
	end

	return splits, sum(beams)
end
