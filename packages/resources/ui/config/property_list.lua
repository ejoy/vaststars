local property_list = {
	["health"] = {
		icon = "property/health.png",
		desc = "建筑生命: ",
		value = "$health$/$total_health$",
		pos = 1,
	},
	["fluid_name"] = {
		icon = "property/fluid_name.png",
		desc = "液体类型: ",
		value = "$fluid_name$",
		pos = 2,
	},
	["fluid_volume"] = {
		icon = "property/fluid_volume.png",
		desc = "液体容量: ",
		value = "$fluid_volume$",
		pos = 3,
	},
}

return property_list