local settings_manager = import_package "vaststars.settings_manager"

local resolution2HD = {
    ["1280x720"] = "720p",
    ["1920x1080"] = "1080p",
}

return function (window, document, ...)
    local window_size = resolution2HD[settings_manager.get("window_size", "1280x720")]
    local start = window.createModel({
        tabs = {
            {name = "游戏设置"},
            {name = "图像设置"},
        },
        name = "游戏设置",
        info = settings_manager.get("info", true),
        debug = settings_manager.get("debug", false),
        music = false,
        window_size = window_size,
        show_window_size = window_size == "720p",
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
        start.info = not settings_manager.get("info", true)
        settings_manager.set("info", start.info)
        window.callMessage("settings|info", start.info)
    end

    function start.clickArchiving()
        window.open("/pkg/vaststars.resources/ui/archiving.html")
        window.close()
    end

    function start.clickMusic()
        start.music = not start.music
    end

    function start.clickWindowSize()
        local r = settings_manager.get("window_size", "1280x720")
        if r == "1280x720" then
            r = "1920x1080"
        else
            r = "1280x720"
        end
        start.window_size = resolution2HD[r]
        start.show_window_size = start.window_size == "720p"
        settings_manager.set("window_size", r)
        window.callMessage("settings|window_size", r)
    end

    function start.clickDebug()
        start.debug = not settings_manager.get("debug", false)
        settings_manager.set("debug", start.debug)
        window.callMessage("settings|debug", start.debug)
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
