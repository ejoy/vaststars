local ltask = require "ltask"

local M = {}

local tconcat = table.concat
local tinsert = table.insert
local srep = string.rep

local function debugstring(root)
	if type(root) ~= "table" then
		return tostring(root)
	end
	local cache = {  [root] = "." }
	local function _dump(t,space,name)
		local temp = {}
		for k,v in pairs(t) do
			local key = tostring(k)
			if cache[v] then
				tinsert(temp,"+" .. key .. " {" .. cache[v].."}")
			elseif type(v) == "table" then
				local new_key = name .. "." .. key
				cache[v] = new_key
				tinsert(temp,"+" .. key .. _dump(v,space .. (next(t,k) and "|" or " " ).. srep(" ",#key),new_key))
			else
				tinsert(temp,"+" .. key .. " [" .. tostring(v).."]")
			end
		end
		return tconcat(temp,"\n"..space)
	end
	return _dump(root, "","")
end

local ServiceGame

function M.get(path, q)
	ServiceGame = ServiceGame or ltask.queryservice "ant.window|window"
	local cmd, path = path:match "^([^/]+)/(.*)"
	print(cmd, path)
	local debug = ltask.call(ServiceGame, cmd, path, q)
	return 200, debugstring(debug)
end

return M
