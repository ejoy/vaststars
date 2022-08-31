local ui_sys = require "ui_system"
local start = ui_sys.createDataMode("start", {
    object_id = 0,
    background = "",
    is_headquater = false,
    item_category = {},
    inventory = {},
    prototype_name = "",
    sub_inventory = {},
    cur_item_category = "",
    item_info = {},
    item_prototype_name = "",

    max_slot_count = 0,
    slot_count = 0,
    show_item_info = false,
    show = false,
    guide_progress = 0,
})

function start.ClickBuilding(event)
    start.show = not start.show
    console.log("---ClickBuilding---")
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
        start.slot_count = math.max(start.max_slot_count, start.slot_count)
    end
    start("sub_inventory")
    
    -- <!-- tag page begin -->
    start.page:on_dirty_all(start.slot_count)
    start.page:show_detail(select_item_index, true)
    -- <!-- tag page end -->
end

function start.clickClose(event)
    ui_sys.close()
end

function start.clickCategory(event, category)
    start.cur_item_category = category
    start.page:show_detail(select_item_index, false)
    select_item_index = nil
    update_category(category)
end

function start.clickToChest(event, index)
    if start.sub_inventory[index] then
        ui_sys.pub {"to_chest", start.object_id, start.sub_inventory[index].id}
        -- <!-- tag page begin -->
        start.page:show_detail(select_item_index, false)
        select_item_index = nil
        -- <!-- tag page end -->
    end
end

function start.clickToHeadquater(event, index)
    if start.sub_inventory[index] then
        ui_sys.pub {"to_headquater", start.object_id, start.sub_inventory[index].id}
        -- <!-- tag page begin -->
        start.page:show_detail(select_item_index, false)
        select_item_index = nil
        -- <!-- tag page end -->
    end
end

function start.clickBlankSlot(event)
    start.page:show_detail(select_item_index, false)
    select_item_index = nil
    if not start.is_headquater then
        ui_sys.open("headquater_inventory.rml", start.object_id)
    end
end

function start.clickBlank(event)
    start.page:show_detail(select_item_index, false)
    select_item_index = nil
end

function start.clickManual(event)
    ui_sys.open("manual_pop.rml")
end

-- <!-- tag page begin -->
local function page_item_update(item, index)
    item.removeEventListener('click')
    if index > #start.sub_inventory then
        --if index <= start.slot_count then
            item.outerHTML = '<div class="item" style="width:100%; height:100%;"/>'
        --end
        if index <= start.slot_count then
            item.addEventListener('click', start.clickBlankSlot)
        else
            item.addEventListener('click', start.clickBlank)
        end
    else
        item.outerHTML = ([[<div class="item" style="width:100%%; height:100%%; background-size: cover; backgroundImage: %s;"> <div class="item-count">%s</div> </div>]]):format(start.sub_inventory[index].icon, start.sub_inventory[index].count)
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
                start.page:show_detail(select_item_index, false)
            end
            select_item_index = index
            start.page:show_detail(select_item_index, true)
            ui_sys.pub {"click_item", start.sub_inventory[index].id}
        end)
    end
end

local function page_item_init(item, index)
    -- item.style.width = '14.07vmin'
    -- item.style.height = '14.07vmin'
    page_item_update(item, index)
end

local function page_item_detail_renderer(index)
    if start.is_headquater then -- only normal box would show item's detail
        return
    end
    local detail = document.createElement "div"
    detail.outerHTML = ([[
            <div class="button-exchange-block" style = "background-color: rgb(203, 118, 24); width: 88vmin; height: 12vmin; border: 1px rgb(89, 73, 39);" data-if="guide_progress >= 10">
                <button class="button-exchange" style = "background-color: rgb(0,176,80); width: 30.00vmin;" data-event-click = "clickToChest(%s)">
                    <div class = "button-exchange-box" style='width:8vmin; height:8vmin; background-image: "textures/cmdcenter/send_material.texture";'/>
                    <div class = "button-exchange-text">指挥中心转箱子</div>
                </button>
                <button class="button-exchange" style = "background-color: rgb(0,176,80); width: 30.00vmin;" data-event-click = "clickToHeadquater(%s)">
                    <div class = "button-exchange-box" style='width:8vmin; height:8vmin; background-image: "textures/cmdcenter/fetch_material.texture";'/>
                    <div class = "button-exchange-text">箱子转指挥中心</div>
                </button>
            </div>
    ]]):format(index, index)
    return detail
end

local pageclass = require "page"
window.customElements.define("page", function(e)
    start.page = pageclass.create(document, e, page_item_init, page_item_update, page_item_detail_renderer)
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