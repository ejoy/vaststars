local t = {}
for k, v in pairs(require "template.loading-scene") do
    t[k] = v
end
t.init_ui = {
    "/pkg/vaststars.resources/ui/login.html",
    "/pkg/vaststars.resources/ui/tutorial_list.html",
}

return t