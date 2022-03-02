local ecs = ...
local world = ecs.world
local w = world.w

local ui_get_route_endpoints = world:sub {"ui", "GET_DATA", "route_endpoints"}
local ui_get_routes = world:sub {"ui", "GET_DATA", "routes"}
local ui_add_route_mb = world:sub {"ui", "route_new", "add_route"}

local route_sys = ecs.system "route_system"

function route_sys:init_world()
    ecs.create_entity({
        policy = {
            "vaststars.gamerender|route_data",
        },
        data = {
            route_max_id = 0,
            route_endpoints = {},
            routes = {},
        }
    })
end

function route_sys:entity_init()
    local route_data = w:singleton("route_endpoints", "route_endpoints:in routes:in")
    if route_data then
        for e in w:select "INIT scene:in route_endpoint:in name:in" do
            route_data.route_endpoints[e.scene.id] = e.reference
        end
        w:sync("route_endpoints:out routes:out", route_data)
    end
end

function route_sys:entity_remove()
    local route_data = w:singleton("route_endpoints", "route_endpoints:in routes:in")
    if route_data then
        for e in w:select "REMOVED scene:in route_endpoint:in" do
            route_data.route_endpoints[e.scene.id] = nil
        end
        w:sync("route_endpoints:out routes:out", route_data)
    end
end

local function get_route_endpoint_name(endpoint_id)
    local route_data = w:singleton("route_endpoints", "route_endpoints:in routes:in")
    local e = route_data.route_endpoints[endpoint_id]
    if not e then
        return ""
    end

    w:sync("name:in", e)
    return e.name
end

function route_sys:data_changed()
    for _ in ui_get_route_endpoints:each() do
        local route_data = w:singleton("route_endpoints", "route_endpoints:in routes:in")
        local t = {}
        for _, e in pairs(route_data.route_endpoints) do
            w:sync("name:in", e)
            t[#t + 1] = {id = e.scene.id, name = e.name}
        end
        world:pub {"ui_message", "SET_DATA", {["route_endpoints"] = t}}
    end

    for _ in ui_get_routes:each() do
        local route_data = w:singleton("route_endpoints", "route_endpoints:in routes:in")
        local t = {}
        for route_id, v in pairs(route_data.routes) do
            t[#t + 1] = {id = route_id, name_1 = get_route_endpoint_name(v[1]), name_2 = get_route_endpoint_name(v[2])}
        end
        world:pub {"ui_message", "SET_DATA", {["routes"] = t}}
    end

    for _, _, _, endpoint_ids in ui_add_route_mb:unpack() do
        local route_data = w:singleton("route_endpoints", "route_endpoints:in routes:in route_max_id:in")
        route_data.route_max_id = route_data.route_max_id + 1
        route_data.routes[route_data.route_max_id] = endpoint_ids
        w:sync("route_max_id:out routes:out", route_data)
        world:pub {"ui", "GET_DATA", "routes"}
    end
end
