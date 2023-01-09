window.customElements.define("collapsed-bar", function(e)
    local function flush(e)
        if e.attributes.expanded == "false" then
            e.attributes.expanded = "true"
            e.style.width = e.attributes["max-width"]
            e.style.transition = "width transform 0.4s linear-in"
        else
            e.attributes.expanded = "false"
            e.style.width = e.attributes["min-width"]
            e.style.transition = "width transform 0.4s linear-out"
        end
    end
    if e.attributes["init-expanded"] == "true" then
        e.attributes.expanded = "false"
    else
        e.attributes.expanded = "true"
    end
    flush(e)
    e.addEventListener('click', function(event)
        flush(e)
    end)
end)