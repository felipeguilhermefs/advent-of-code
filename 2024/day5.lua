local HashMap = require("ff.collections.hashmap")

local function Node(value)
	return { value = value, children = HashMap.new() }
end

local function addNodes(nodes, prev, next)
	local prevNode = nodes:compute(prev, Node)
	local nextNode = nodes:compute(next, Node)

	prevNode.children:put(next, nextNode)
end

local function findSafeMiddle(nodes, line)
	local pages = {}

	for value in line:gmatch("(%d+)") do
		local node = nodes:get(value)
		if node == nil then
			return 0
		end
		table.insert(pages, value)

		nodes = node.children
	end

	return pages[math.floor(#pages / 2) + 1]
end

local function part1()
	local sum = 0
	local nodes = HashMap.new()
	for line in io.lines(arg[1]) do
		local prev, next = line:match("(%d+)|(%d+)")
		if prev then
			addNodes(nodes, prev, next)
		elseif line ~= "" then
			sum = sum + findSafeMiddle(nodes, line)
		end
	end

	return sum
end

local function findUnsafeMiddle(nodes, line)
	local pages = {}

	for value in line:gmatch("(%d+)") do
		local node = nodes:get(value)
		table.insert(pages, node)
	end

	local safe = true
	for _, page in pairs(pages) do
		local node = nodes:get(page.value)
		if node == nil then
			safe = false
			break
		end
		nodes = node.children
	end

	if safe then
		return 0
	end

	table.sort(pages, function(a, b)
		return a.children:contains(b.value)
	end)

	return pages[math.floor(#pages / 2) + 1].value
end

local function part2()
	local sum = 0
	local nodes = HashMap.new()
	for line in io.lines(arg[1]) do
		local prev, next = line:match("(%d+)|(%d+)")
		if prev then
			addNodes(nodes, prev, next)
		elseif line ~= "" then
			sum = sum + findUnsafeMiddle(nodes, line)
		end
	end

	return sum
end

print("Part 1", part1())
print("Part 2", part2())
