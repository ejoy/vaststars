local aio = import_package "ant.io"
local datalist = require "datalist"
local function read_datalist(path)
    return datalist.parse(aio.readall(path))
end

return {
    read = read_datalist,
}