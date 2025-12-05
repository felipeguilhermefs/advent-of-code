-- Define the RangeTree class
RangeTree = {}
RangeTree.__index = RangeTree

function RangeTree.new()
	return setmetatable({ root = nil }, RangeTree)
end

-------------------------------------------------------------------------
-- SEARCH METHOD
-------------------------------------------------------------------------

-- Returns true if 'value' is contained in any range in the tree
function RangeTree:contains(value)
	local current = self.root
	while current do
		if value >= current.min and value <= current.max then
			return true -- Found inside this range
		elseif value < current.min then
			current = current.left
		else
			current = current.right
		end
	end
	return false
end

-------------------------------------------------------------------------
-- INSERT METHOD (With Merge Logic)
-------------------------------------------------------------------------

function RangeTree:insert(newMin, newMax)
	-- Ensure min is actually smaller than max
	if newMin > newMax then
		newMin, newMax = newMax, newMin
	end

	-- 1. Identify and remove any existing nodes that overlap with the new range
	-- We keep expanding our [newMin, newMax] to include the removed ranges.
	while true do
		local overlapNode = self:_findOverlappingNode(self.root, newMin, newMax)

		if not overlapNode then
			break -- No more overlaps found
		end

		-- Merge the bounds
		newMin = math.min(newMin, overlapNode.min)
		newMax = math.max(newMax, overlapNode.max)

		-- Remove the old node (we will re-insert the bigger range later)
		self.root = self:_deleteNode(self.root, overlapNode.min)
	end

	-- 2. Insert the final combined range
	self.root = self:_insertNode(self.root, newMin, newMax)
end

-------------------------------------------------------------------------
-- INTERNAL HELPERS (Private)
-------------------------------------------------------------------------

-- Standard BST Insertion
function RangeTree:_insertNode(node, min, max)
	if not node then
		return { min = min, max = max, left = nil, right = nil }
	end

	if min < node.min then
		node.left = self:_insertNode(node.left, min, max)
	else
		node.right = self:_insertNode(node.right, min, max)
	end
	return node
end

-- Find any single node that overlaps with [min, max]
function RangeTree:_findOverlappingNode(node, min, max)
	if not node then
		return nil
	end

	-- Overlap condition: (StartA <= EndB) and (EndA >= StartB)
	if node.min <= max and node.max >= min then
		return node
	end

	if min < node.min then
		return self:_findOverlappingNode(node.left, min, max) or self:_findOverlappingNode(node.right, min, max)
	else
		return self:_findOverlappingNode(node.right, min, max) or self:_findOverlappingNode(node.left, min, max)
	end
end

-- Standard BST Deletion (deletes by the unique 'min' key)
function RangeTree:_deleteNode(node, key)
	if not node then
		return nil
	end

	if key < node.min then
		node.left = self:_deleteNode(node.left, key)
	elseif key > node.min then
		node.right = self:_deleteNode(node.right, key)
	else
		-- Node found. Handle the 3 deletion cases:

		-- Case 1: No child (Leaf)
		if not node.left and not node.right then
			return nil
		end

		-- Case 2: One child
		if not node.left then
			return node.right
		end
		if not node.right then
			return node.left
		end

		-- Case 3: Two children
		-- Find successor (smallest node in right subtree)
		local successor = node.right
		while successor.left do
			successor = successor.left
		end

		-- Copy successor data to current node
		node.min = successor.min
		node.max = successor.max

		-- Delete the original successor node
		node.right = self:_deleteNode(node.right, successor.min)
	end
	return node
end

-- Helper to visualize the tree (In-order traversal)
function RangeTree:printTree()
	return self:traverse(self.root)
end

function RangeTree:traverse(node)
	if not node then
		return 0
	end
	local sum = self:traverse(node.left)
	sum = sum + node.max - node.min + 1
	-- print(string.format("[%d, %d]", node.min, node.max))
	return sum + self:traverse(node.right)
end

return function(filepath)
	local ranges = RangeTree.new()

	local rangesFinished = false
	local count = 0
	for line in io.lines(filepath) do
		if rangesFinished then
			if ranges:contains(tonumber(line)) then
				count = count + 1
			end
		else
			if line == "" then
				rangesFinished = true
			else
				local min, max = line:match("(%d+)-(%d+)")
				ranges:insert(tonumber(min), tonumber(max))
			end
		end
	end

	return count, ranges:printTree()
end
