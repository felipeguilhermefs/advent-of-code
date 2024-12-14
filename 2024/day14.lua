local Set = require("ff.collections.set")

local HEIGHT = 103
local WIDTH = 101

local HALF_H = math.floor(HEIGHT / 2)
local HALF_W = math.floor(WIDTH / 2)

local function readInput()
	local robots = {}
	for line in io.lines(arg[1]) do
		local robot = {}
		for num in line:gmatch("-?%d+") do
			table.insert(robot, tonumber(num))
		end
		table.insert(robots, robot)
	end
	return robots
end

local function move(pos, vel, limit, times)
	times = times or 1
	return (pos + vel * times) % limit
end

local function calculateSafety(robots)
	local quadrants = { 0, 0, 0, 0 }
	for _, robot in pairs(robots) do
		local x = move(robot[1], robot[3], WIDTH, 100)
		local y = move(robot[2], robot[4], HEIGHT, 100)

		if x < HALF_W and y < HALF_H then
			quadrants[1] = quadrants[1] + 1
		elseif x > HALF_W and y < HALF_H then
			quadrants[2] = quadrants[2] + 1
		elseif x < HALF_W and y > HALF_H then
			quadrants[3] = quadrants[3] + 1
		elseif x > HALF_W and y > HALF_H then
			quadrants[4] = quadrants[4] + 1
		end
	end

	local safetyFactor = 1
	for _, count in pairs(quadrants) do
		safetyFactor = safetyFactor * count
	end
	return safetyFactor
end

local function untilXmasTree(robots)
	local seconds = 1

	while true do
		local visited = Set.new()
		for i, robot in ipairs(robots) do
			robots[i][1] = move(robot[1], robot[3], WIDTH)
			robots[i][2] = move(robot[2], robot[4], HEIGHT)
			visited:add(string.format("%d:%d", robots[i][1], robots[i][2]))
		end

		if #visited == #robots then
			return seconds
		end

		seconds = seconds + 1
	end
end

local function run()
	local robots = readInput()

	return calculateSafety(robots), untilXmasTree(robots)
end

local part1, part2 = run()
print("Part 1", part1)
print("Part 2", part2)
