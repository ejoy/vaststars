local list_meta = {}
list_meta.__index = list_meta

function list_meta.create(document, e, item_init, item_update, detail_renderer, data_for)
    local list = {
        direction   = tonumber(e.getAttribute("direction")),
        width       = e.getAttribute("width"),
        height      = e.getAttribute("height"),
        item_count  = 0,
        pos         = 0,
        drag        = {mouse_pos = 0, anchor = 0, delta = 0},
        item_init   = item_init,
        item_update = item_update,
        detail_renderer = detail_renderer,
        document    = document,
        data_for    = data_for
    }
    setmetatable(list, list_meta)
    e.style.overflow = 'scroll'
    e.style.width = list.width
    e.style.height = list.height
    local panel
    if data_for then
        panel = item_init()
    else
        panel = document.createElement "div"
        list.item_map = {}
        list.index_map = {}
    end
    panel.className = "liststyle"
    panel.className = panel.className .. " notransition"
    panel.style.width = list.width
    if list.direction == 0 then
        panel.style.height = '100%'--list.height
        panel.style.flexDirection = 'row'
    else
        panel.style.width = '100%'--list.width
        panel.style.flexDirection = 'column'
    end
    panel.style.alignItems = 'center'
    panel.style.justifyContent = 'flex-start'
    -- panel.addEventListener('mousedown', function(event) list:on_mousedown(event) end)
    -- panel.addEventListener('mousemove', function(event) list:on_drag(event) end)
    -- panel.addEventListener('mouseup', function(event) list:on_mouseup(event) end)
    panel.addEventListener('pan', function(event) list:on_pan(event) end)
    e.appendChild(panel)
    list.panel = panel
    list.view = e
    list:on_dirty_all(0)
    return list
end

-- function list_meta:set_selected(item)
--     if self.selected == item then
--         return false
--     end
--     self.selected = item
--     return true
-- end

-- function list_meta:get_selected()
--     return self.selected
-- end

function list_meta:get_item(index)
    return self.index_map[index].item
end

-- function list_meta:set_list_size(width, height)
--     self.width = width
--     self.height = height
--     self:on_dirty()
-- end

-- function list_meta:set_item_count(count)
--     self.item_count = count
--     self:on_dirty()
-- end
function list_meta:reset_position()
    self.pos = 0
    local oldClassName = self.panel.className
    self.panel.className = self.panel.className .. " notransition"
    if self.direction == 0 then
        self.panel.style.left = '0px'
    else
        self.panel.style.top = '0px'
    end
    self.panel.className = oldClassName
end

function list_meta:on_dirty(index)
    if index > 0 and index <= #self.index_map then
        self.item_update(self.index_map[index].item, index)
    end
end

function list_meta:create_item(index)
    local item = self.document.createElement "div"
    self.item_init(item, index)
    self.panel.appendChild(item)
    local item_info = {index = index, detail = false, item = item}
    self.item_map[item] = item_info
    self.index_map[#self.index_map + 1] = item_info
end

function list_meta:on_dirty_all(item_count)
    if self.data_for then
        return
    end
    local total_item_count = #self.index_map
    for new_idx = total_item_count + 1, item_count do
        self:create_item(new_idx)
    end
    local index_map = {}
    for index = 1, item_count do
        local item = self.index_map[index].item
        self.item_update(item, index)
        index_map[#index_map + 1] = self.index_map[index]
    end
    for empty_idx = item_count + 1, total_item_count do
        local item = self.index_map[empty_idx].item
        self.item_map[item] = nil
        self.panel.removeChild(item)
    end
    self.index_map = index_map
    self.item_count = item_count
    self.min_pos = nil
    self.pos = 0
end

function list_meta:show_detail(it, show)
    if not self.index_map or not self.item_map then
        return
    end
    local iteminfo
    if type(it) == "number" then
        iteminfo = self.index_map[it]
    else
        iteminfo = self.item_map[it]
    end
     
    if not iteminfo then
        return
    end
    if show then
        if not iteminfo.detail and self.detail_renderer then
            self.detail = self.detail_renderer(iteminfo.index)
            iteminfo.item.parentNode.appendChild(self.detail, iteminfo.index)
            iteminfo.detail = true
        end
    else
        if iteminfo.detail and self.detail then
            local parent = self.detail.parentNode
            parent.removeChild(self.detail)
            self.detail = nil
            iteminfo.detail = false
        end
    end
end

function list_meta:on_pan(event)
    if self.direction == 0 then
        if event.state == 'began' then
            self.last_x = event.x
            return
        end
        local detla = event.x - self.last_x
        if detla == 0 then
            return
        end
        self.last_x = event.x
        local e = self.view
        e.scrollLeft = e.scrollLeft - 2 * detla
    else
        if event.state == 'began' then
            self.last_y = event.y
            return
        end
        local detla = event.y - self.last_y
        if detla == 0 then
            return
        end
        self.last_y = event.y
        local e = self.view
        e.scrollTop = e.scrollTop - 2*detla
    end
end

return list_meta
