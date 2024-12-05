local function Node(value)
	return { value = value, children = {} }
end

local function addNodes(nodes, prev, next)
	if nodes[prev] == nil then
		nodes[prev] = Node(prev)
	end
	local prevNode = nodes[prev]

	if nodes[next] == nil then
		nodes[next] = Node(next)
	end
	local nextNode = nodes[next]

	prevNode.children[next] = nextNode
end

local function findSafeMiddle(nodes, line)
	local pages = {}
	for value in line:gmatch("(%d+)") do
		local node = nodes[value]
		if node == nil then
			return 0
		end
		table.insert(pages, value)

		nodes = node.children
	end

	if #pages % 2 == 0 then
		print("DANGER!!! EVEN !!!")
	end
	return pages[math.floor(#pages / 2) + 1]
end

local function part1()
	local sum = 0
	local nodes = {}
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

print("Part 1", part1())
