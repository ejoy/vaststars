local ui_sys = require "ui_system"
local start = ui_sys.createDataMode("start", {
    items = {},
    total = 0,
    label_x = {},
    label_y = {}
})

function start.ClickBuilding(event)
    start.show = not start.show
end

function start.ClickBack(event)
    start.show_item_info = false
    start.show = false
end

local function update_category()
    -- <!-- tag page begin -->
    start.page:on_dirty_all(#start.items)
    -- <!-- tag page end -->
end

function start.clickReturn(event)
    ui_sys.close()
end

function start.onFilterType(event, type)
    ui_sys.pub {"statistics", "filter_type", type}
end

function start.onChartType(event, type)
    ui_sys.pub {"statistics", "chart_type", type}
end

-- <!-- tag page begin -->
local function page_item_update(item, index)
    -- item.removeEventListener('click')
    if index > #start.items then
        return
    else
        local itemdata = start.items[index]
        item.outerHTML = ([[
            <div class="building-sub-content">
                <div class="building-content">
                    <div class="indicator" style="height: %d%%; background-color: rgb(%d, %d, %d);"/>
                    <div class="item" style='background-image: %s;'>
                        <div class="item-count">%s</div>
                    </div>
                </div>
            </div>
        ]]):format(math.floor(itemdata.power / start.total * 100), itemdata.color[1], itemdata.color[2], itemdata.color[3], itemdata.icon, itemdata.count)
        -- item.outerHTML = ([[
        --     <div class="single-item-block">
        --         <div class="single-item">
        --             <div class="single-item-icon" style = "background-image: %s;" />
        --             <div class="single-item-title">%s</div>
        --         </div>
        --         <div class = "single-item-title" style="font-size: 4vmin; text-align: left;">X %s</div>
        --     </div>
        -- ]]):format(start.items[index].icon, start.items[index].name, start.items[index].count)
        -- if select_item_index ~= index then
        --     item.style.border = unselect_style_border
        -- else
        --     item.style.border = select_style_border
        -- end
        item.addEventListener('click', function(event)
            -- item.style.border = select_style_border
            -- if select_item_index then
            --     local v = start.page:get_item_info(select_item_index)
            --     if v then
            --         v.item.style.border = unselect_style_border
            --     end
            -- end
            -- select_item_index = index
            -- ui_sys.pub {"click_item", start.items[index].id}
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
            update_category()
        end,
        "items"
    }
})