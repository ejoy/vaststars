local function scrollToItem(tagName, elementId)
    for _, list in ipairs(document.getElementsByTagName(tagName)) do
        local item = document.getElementById(elementId)
        if item then
            local clientTop = 0
            local e = item
            repeat
                clientTop = clientTop + e.clientTop
                e = e.parentNode
            until e == list

            if clientTop >= list.scrollTop and (clientTop + item.clientHeight) <= (list.scrollTop + list.clientHeight) then
                return
            end

            list.scrollTop = clientTop
        end
    end
end

return scrollToItem