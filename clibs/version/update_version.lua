local path = ...
local p <close> = assert(io.popen("git log -n 1 --pretty=format:\"return '%ad'\" --date=iso"))
local f <close> = assert(io.open(path, 'w'))
f:write(p:read "a")
