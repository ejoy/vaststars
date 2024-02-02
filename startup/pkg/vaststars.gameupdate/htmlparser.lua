local self_closing_tags <const> = {
    area = true,
    base = true,
    br = true,
    embed = true,
    hr = true,
    img = true,
    input = true,
    link = true,
    meta = true,
    param = true,
    source = true,
    track = true,
    wbr = true,
}

local function parse_attr(s)
    local attr = {}
---@diagnostic disable-next-line: discard-returns
    string.gsub(s, "([%-%w]+)=([\"'])(.-)%2", function(w, _, a)
        attr[w] = a
    end)
    return attr
end

return function (str)
    local top = {}
    local stack = { top }
    local ni, c, tag, attr, empty
    local i, j = 1, 1
    while true do
        ni, j, c, tag, attr, empty = string.find(str, "<(%/?)([%w:]+)(.-)(%/?)>", i)
        if not ni then
            break
        end
        local text = string.sub(str, i, ni - 1)
        if not string.find(text, "^%s*$") then
            top[#top+1] = text
        end
        if self_closing_tags[tag] or empty == "/" then
            top[#top+1] = {
                tag = tag,
                attr = parse_attr(attr),
            }
        elseif c == "" then
            top = {
                tag = tag,
                attr = parse_attr(attr),
            }
            stack[#stack+1] = top
        else
            local toclose = table.remove(stack)
            top = stack[#stack]
            if #stack < 1 then
                error("nothing to close with " .. tag)
            end
            if toclose.tag ~= tag then
                error("trying to close " .. toclose.tag .. " with " .. tag)
            end
            top[#top+1] = toclose
        end
        i = j + 1
    end
    local text = string.sub(str, i)
    if not string.find(text, "^%s*$") then
        local back = stack[#stack]
        back[#back+1] = text
    end
    if #stack > 1 then
        error("unclosed " .. stack[#stack].tag)
    end
    return stack[1]
end
