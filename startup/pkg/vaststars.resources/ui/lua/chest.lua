local ui_sys = require "ui_system"
local start = ui_sys.createDataMode("start", {
    object_id = 0,
    item_category = {},
    inventory = {},
    prototype_name = "",
    sub_inventory = {},
    cur_item_category = "",
    item_info = {},
    entities = {},
    item_prototype_name = "",

    max_slot_count = 0,
    slot_count = 0,
    show_item_info = false,
    show = false,
    guide_progress = 0,
})

function start.ClickBuilding(event)
    start.show = not start.show
end

function start.ClickBack(event)
    start.show_item_info = false
    start.show = false
end

-- <!-- tag page begin -->
local select_item_index
-- <!-- tag page end -->
local select_style_border   = "0.54vmin green"
local unselect_style_border = "0.54vmin rgb(89, 73, 39)"
local function update_category(category)
    start.sub_inventory = {}
    for _, v in ipairs(start.inventory) do
        if v.category == category or category == "全部" then
            start.sub_inventory[#start.sub_inventory + 1] = v
        end
    end

    start.slot_count = #start.sub_inventory
    if category == "全部" then
        start.slot_count = math.min(start.max_slot_count, start.slot_count)
    end
    start("sub_inventory")

    -- <!-- tag page begin -->
    start.page:on_dirty_all(start.slot_count)
    -- <!-- tag page end -->
end

function start.clickClose(event)
    ui_sys.pub {"close_chestui"}
    ui_sys.close()
end

function start.clickCategory(event, category)
    start.cur_item_category = category
    select_item_index = nil
    update_category(category)
end

-- <!-- tag page begin -->
local function page_item_update(item, index)
    item.removeEventListener('click')
    if index > #start.sub_inventory then
        return
    else
        item.outerHTML = ([[
            <div class="single-item-block">
                <div class="single-item">
                    <div class="single-item-icon" style = "background-image: %s;" />
                    <div class="single-item-title">%s</div>
                </div>
                <div class = "single-item-title" style="font-size: 4vmin; text-align: left;">X %s</div>
            </div>
        ]]):format(start.sub_inventory[index].icon, start.sub_inventory[index].name, start.sub_inventory[index].count)
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
            ui_sys.pub {"click_item", start.sub_inventory[index].id}
        end)
    end
end

local page_item_init = page_item_update

local pageclass = require "page"
window.customElements.define("page", function(e)
    start.page = pageclass.create(document, e, page_item_init, page_item_update)
end)
-- <!-- tag page end -->

ui_sys.mapping(start, {
    {
        function()
            if start.cur_item_category == "" and start.item_category[1] then
                start.cur_item_category = start.item_category[1].category or ""
            end
            if start.cur_item_category == "" then
                start.cur_item_category = start.item_category[1]
            end
            update_category(start.cur_item_category)
        end,
        "inventory", "item_category"
    }
})