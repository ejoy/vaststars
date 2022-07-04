local object_id = 0
local function get_object_id()
    object_id = object_id + 1
    return object_id
end

return {
    get_object_id = get_object_id,
    mode = "normal",
    fluidflow_id = 0,
    science = {}
}
