local ui_sys = require "ui_system"
local start = window.createModel "start" {
    mode = "init", -- "init"/"fuel"/"material"/"plugin"
    machine_item = false,

    prototype_name = " ",
    background = "",
    recipe_name = " ",
    object_id = 0,
    recipe_ingredients = {}, -- 配方成份
    recipe_results = {},     -- 配方产出

    recipe_ingredients_count = {}, -- 组装机成份材料个数 = {{icon = xx, count = xx}, ...}
    recipe_results_count = {},     -- 组装机产出材料个数 = {{icon = xx, count = xx}, ...}
    process = 0, -- 进度
    inventory = {}, -- {{icon = xx, count = xx, name = xx}, ...}
}

function start.ClickMachineItem(event)
    start.machine_item = not start.machine_item
end

function start.ClickFuel(event)
    start.mode = "fuel"
end

function start.ClickMaterial(event)
    -- start.mode = "material"
end

function start.ClickPlugin(event)
    start.mode = "plugin"
end

function start.ClickBack(event)
    start.mode = "init"
    start.machine_item = false
end

function start.ClickClose(event)
    ui_sys:close()
end

function start.clickRecipe(event)
    ui_sys:world_pub {"rmlui_message_pub", "build_function_pop.rml", "recipe", start.object_id}
end

-- <!-- tag page begin -->
local select_item_index
-- <!-- tag page end -->

ui_sys:setDataModel(start, function(patch)
    if patch.inventory then
        -- <!-- tag page begin -->
        start.page:on_dirty_all(#start.inventory)
        if select_item_index then
            local v = start.page:get_item_info(select_item_index)
            start.page:show_detail(v, true)
        end
        -- <!-- tag page end -->
    end
end)

-- <!-- tag page begin -->
local function page_item_renderer(index)
    if index > #start.inventory then
        local e = document.createElement "div"
        e.outerHTML = ([[<div style = "width: %0.2fvmin; height: %0.2fvmin;" />]]):format(12 + 0.27, 12 + 0.27)
        return e
    end

    local item = document.createElement "div"
    item.outerHTML = ([[<div class = "item" style = "backgroundImage: %s"> <div class="item-count">%s</div> </div>]]):format(start.inventory[index].icon, start.inventory[index].count)

    local select_style_border   = "0.27vmin green"
    local unselect_style_border = "0.27vmin rgb(89, 73, 39)"
    if select_item_index ~= index then
        item.style.border = unselect_style_border
    else
        item.style.border = select_style_border
    end

    item.addEventListener('click', function(event)
        item.style.border = select_style_border
        if select_item_index then
            local v = start.page:get_item_info(select_item_index)
            if v then
                v.item.style.border = unselect_style_border
            end
        end
        select_item_index = index

        start.page:show_detail(item, false)
        start.page:show_detail(item, true)
    end)
    return item
end

local pageclass = require "page"
window.customElements.define("page", function(e)
    start.page = pageclass.create(document, e, page_item_renderer)
end)
-- <!-- tag page end -->