local Array = require("ff.collections.array")
local HashMap = require("ff.collections.hashmap")

local function nextSecret(seed, iterations)
	local secret = seed
	local prices = Array.new()
	for _ = 1, iterations do
		secret = ((secret * 64) ~ secret) % 16777216
		secret = (math.floor(secret / 32) ~ secret) % 16777216
		secret = ((secret * 2048) ~ secret) % 16777216

		prices:insert(secret % 10)
	end
	return secret, prices
end

local function generateSequences(prices)
	local changes = Array.new()
	for i = 2, #prices do
		changes:insert(prices:get(i) - prices:get(i - 1))
	end

	local sequences = HashMap.new()
	for i = 4, #changes do
		local key =
			string.format("%d:%d:%d:%d", changes:get(i - 3), changes:get(i - 2), changes:get(i - 1), changes:get(i))
		if not sequences:contains(key) then
			sequences:put(key, prices:get(i + 1))
		end
	end
	return sequences
end

local function max(sequences)
	local maximum = 0
	for _, count in pairs(sequences) do
		if count > maximum then
			maximum = count
		end
	end
	return maximum
end

local function add(a, b)
	return a + b
end

return function(filepath)
	local sumPrices = 0
	local sequences = HashMap.new()
	for line in io.lines(filepath) do
		local seed = tonumber(line)
		local secret, prices = nextSecret(seed, 2000)

		sumPrices = sumPrices + secret

		sequences:merge(generateSequences(prices), add)
	end

	return sumPrices, max(sequences)
end
