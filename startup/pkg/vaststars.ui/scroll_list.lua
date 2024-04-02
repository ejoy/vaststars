
local function init(document, tag_names)
    for _, tag_name in ipairs(tag_names) do
        for _, e in ipairs(document.getElementsByTagName(tag_name)) do
            e.scrollInsets(0, 0, 0, 200)

            local last_y
            e.addEventListener("pan", function(param)
                if last_y and param.state == "changed" then
                    e.scrollTop = e.scrollTop - (param.y - last_y)
                end
                last_y = param.y
            end)
        end
    end
end

return {
    init = init,
}