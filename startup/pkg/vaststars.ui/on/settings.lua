local setting = import_package "vaststars.settings_manager"

return function (window, document, ...)
    local start = window.createModel({
        tabs = {
            {name = "游戏设置"},
            {name = "图像设置"},
        },
        name = "游戏设置",
        info = setting.get("info", true),
        debug = setting.get("debug", false),
        music = false,
    })

    function start.clickTab(name)
        start.name = name
    end

    function start.clickClose()
        window.close()
    end

    function start.clickButton(cmd, close)
        window.sendMessage(cmd)
        if close then
            window.close()
        end
    end

    function start.clickInfo(...)
        start.info = not setting.get("info", true)
        setting.set("info", start.info)
        window.callMessage("settings|info", start.info)
    end

    function start.clickArchiving()
        window.open("/pkg/vaststars.resources/ui/archiving.html")
        window.close()
    end

    --TODO:
    local function _update_option(e, checked)
        local img1 = assert(e.getAttribute("background-image-1"))
        local img2 = assert(e.getAttribute("background-image-2"))
        e.style.backgroundImage = checked and img1 or img2
    end

    function start.clickOption(ev)
        local option_1 = document.getElementById("option-1-point")
        local option_2 = document.getElementById("option-2-point")

        local c = ev.current
        if c == document.getElementById("option-1") then
            _update_option(option_1, true)
            _update_option(option_2, false)
        else
            _update_option(option_1, false)
            _update_option(option_2, true)
        end
    end

    window.customElements.define("option", function(e)
        local checked = assert(e.getAttribute("checked")) == "1"
        local img1 = assert(e.getAttribute("background-image-1"))
        local img2 = assert(e.getAttribute("background-image-2"))

        local function update(checked)
            e.style.backgroundImage = checked and img1 or img2
        end
        update(checked)

        e.addEventListener("update", function(event, checked)
            update(checked)
        end)
    end)

    window.customElements.define("ping-pong", function(e)
        local checked = start[assert(e.getAttribute("bind-var"))]
        local img1 = assert(e.getAttribute("background-image-1"))
        local img2 = assert(e.getAttribute("background-image-2"))
        local txt1 = assert(e.getAttribute("text-1"))
        local txt2 = assert(e.getAttribute("text-2"))

        local text_container = document.createElement("div")
        text_container.style.fontSize = "4.50vmin"
        text_container.style.alignItems = "center"
        text_container.style.justifyContent = "center"
        text_container.style.width = "70%"
        text_container.style.height = "100%"
        local text_node = document.createTextNode("")
        text_container.appendChild(text_node)
        e.appendChild(text_container)

        local function update(checked)
            e.style.backgroundImage = checked and img1 or img2
            e.style.alignItems = checked and "flex-end" or "flex-start"
            text_node.textContent = checked and txt1 or txt2
        end
        update(checked)

        e.addEventListener("click", function(event)
            checked = not checked
            update(checked)
        end)
    end)
end
