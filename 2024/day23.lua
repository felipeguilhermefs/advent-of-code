local HashMap = require("ff.collections.hashmap")
local Set = require("ff.collections.set")

local function newConnections()
	return Set.new()
end

local function id(set)
	local arr = {}
	for item in pairs(set._entries) do
		table.insert(arr, item)
	end
	table.sort(arr)
	return table.concat(arr, ",")
end

local function lan3(connections)
	local lans = HashMap.new()

	for computer, connected in pairs(connections) do
		for conn in pairs(connected._entries) do
			local lan = connected:intersection(connections:get(conn))
			for comp in pairs(lan._entries) do
				if not computer:match("^t") and not conn:match("^t") and not comp:match("^t") then
					goto continue
				end

				local smallLan = Set.new()
				smallLan:add(computer)
				smallLan:add(conn)
				smallLan:add(comp)

				local key = id(smallLan)
				if lans:contains(key) then
					goto continue
				end

				lans:put(key, smallLan)

				::continue::
			end
		end
	end

	return #lans
end

local function combinations(connections, size)
	local arr = {}
	for item in pairs(connections._entries) do
		table.insert(arr, item)
	end
	table.sort(arr)

	local res = {}
	for i = size, #arr do
		local base = Set.new()
		for k = i - size + 1, i - 1 do
			base:add(arr[k])
		end

		for j = i, #arr do
			local combi = base:union(Set.new())
			combi:add(arr[j])
			table.insert(res, combi)
		end
	end
	return pairs(res)
end

local function maxLan(connections)
	local maxCount = 0
	local max = Set.new()
	for computer, connected in pairs(connections) do
		local size = #connected
		while size > maxCount - 1 do
			for _, combi in combinations(connected, size) do
				local lan = combi:union(Set.new())
				lan:add(computer)
				for other in pairs(combi._entries) do
					lan = lan:intersection(connections:get(other))
					lan:add(other)
				end
				if #lan > maxCount then
					maxCount = #lan
					max = lan
				end
			end
			size = size - 1
		end
	end
	return id(max)
end

local function run()
	local connections = HashMap.new()
	for line in io.lines(arg[1]) do
		local computer1, computer2 = line:match("(%a+)-(%a+)")
		connections:compute(computer1, newConnections):add(computer2)
		connections:compute(computer2, newConnections):add(computer1)
	end

	return lan3(connections), maxLan(connections)
end

local part1, part2 = run()
print("Part 1", part1)
print("Part 2", part2)
