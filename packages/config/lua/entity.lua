local prototype = function(...) end

prototype ("组装机1", {
    type = {"pause_animation", "set_road_entry", "pickup_show_remove"},
    prefab = "assembling.prefab",
    construct_detector = "roadside",
})

return {}
