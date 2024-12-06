local HashMap = require("ff.collections.hashmap")

local function Node(value)
	return { value = value, children = HashMap.new() }
end

local function addNodes(nodes, prev, next)
	local prevNode = nodes:compute(prev, Node)
	local nextNode = nodes:compute(next, Node)

	prevNode.children:put(next, nextNode)
end

local function findMiddle(nodes, line)
	local pages = {}

	local safe = true
	local curNodes = nodes
	for value in line:gmatch("(%d+)") do
		local node = curNodes:get(value)
		if node == nil then
			safe = false
		else
			curNodes = node.children
		end
		table.insert(pages, nodes:get(value))
	end

	if not safe then
		table.sort(pages, function(a, b)
			return a.children:contains(b.value)
		end)
	end

	return pages[math.floor(#pages / 2) + 1].value, safe
end

local function run()
	local safeSum, unsafeSum = 0, 0
	local nodes = HashMap.new()
	for line in io.lines(arg[1]) do
		local prev, next = line:match("(%d+)|(%d+)")
		if prev then
			addNodes(nodes, prev, next)
		elseif line ~= "" then
			local middle, safe = findMiddle(nodes, line)
			if safe then
				safeSum = safeSum + findMiddle(nodes, line)
			else
				unsafeSum = unsafeSum + findMiddle(nodes, line)
			end
		end
	end

	return safeSum, unsafeSum
end

local safeSum, unsafeSum = run()
print("Part 1", safeSum)
print("Part 2", unsafeSum)
