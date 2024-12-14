local function readInput()
	local machines = {}
	local machine = {}
	for line in io.lines(arg[1]) do
		if line:match("Button") then
			local x, y = line:match("X%+(%d+), Y%+(%d+)")
			table.insert(machine, { tonumber(x), tonumber(y) })
		elseif line:match("Prize") then
			local x, y = line:match("X=(%d+), Y=(%d+)")
			table.insert(machine, { tonumber(x), tonumber(y) })
			table.insert(machines, machine)
			machine = {}
		end
	end
	return machines
end

local function round(num)
	if num >= 0 then
		return math.floor(num + 0.5)
	end
	return math.ceil(num - 0.5)
end

local function countToken(machines, convert)
	local tokens = 0
	for _, machine in pairs(machines) do
		local aX = machine[1][1]
		local aY = machine[1][2]
		local bX = machine[2][1]
		local bY = machine[2][2]
		local prizeX = machine[3][1]
		local prizeY = machine[3][2]

		if convert then
			prizeX = prizeX + 10000000000000
			prizeY = prizeY + 10000000000000
		end

		local a = round((prizeY - ((bY * prizeX) / bX)) / (aY - ((bY * aX) / bX)))
		local b = round((prizeX - aX * a) / bX)
		if aX * a + bX * b == prizeX and aY * a + bY * b == prizeY then
			tokens = tokens + a * 3 + b
		end
	end
	return tokens
end

local function run()
	local machines = readInput()
	return countToken(machines), countToken(machines, true)
end

local part1, part2 = run()
print("Part 1", part1)
print("Part 2", part2)
