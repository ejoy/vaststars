local function scrollToItem(document, tagName, elementId)
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

            if clientTop < list.scrollTop then
                list.scrollTop = clientTop
            else
                list.scrollTop = clientTop + item.clientHeight - list.clientHeight
            end
        end
    end
end

return scrollToItem