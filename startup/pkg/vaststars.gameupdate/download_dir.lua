local download = require "download"
local htmlparser = require "htmlparser"

local function htmlwalk_(e, func)
    if e.tag then
        func(e)
        for i = 1, #e do
            htmlwalk_(e[i], func)
        end
    end
end

local function htmlwalk(e, func)
    for i = 1, #e do
        htmlwalk_(e[i], func)
    end
end

return function (url)
    local code, content = download(url)
    if code ~= 200 then
        return {}
    end
    local tree = htmlparser(content)
    local res = {}
    htmlwalk(tree, function (e)
        if e.tag == "a" and e.attr.href ~= "../" then
            local filename = e.attr.href
            res[filename] = {
                type = filename:sub(-1) == "/" and "dir" or "file",
                url = url .. filename
            }
        end
    end)
    return res
end
