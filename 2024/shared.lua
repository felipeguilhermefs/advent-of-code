-- lua dayX.lua <input file path>
return {
	input = function()
		local f = assert(io.open(arg[1], "rb"), "Open File")
		local content = f:read("*a")
		f:close()
		return content
	end,
}
