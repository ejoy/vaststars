local property_list = {
	["health"] = {
		icon = "textures/property/building-health.texture",
		desc = "建筑生命: ",
		value = "$health$/$total_health$",
		pos = 1,
	},
	["fluid_name"] = {
		icon = "textures/property/fluid-type.texture",
		desc = "液体类型: ",
		value = "$fluid_name$",
		pos = 2,
	},
	["fluid_volume"] = {
		icon = "textures/property/fluid-volume.texture",
		desc = "液体容量: ",
		value = "$fluid_volume$/$fluid_capacity$",
		pos = 3,
	},
	["fluid_rate"] = {
		icon = "textures/property/fluid-rate.texture",
		desc = "液体流速: ",
		value = "$fluid_flow$",
		pos = 4,
	},
	["chest_capacity"] = {
		icon = "textures/property/chest-capacity.texture",
		desc = "储物箱容量: ",
		pos = 5,
	},
	["chest_req"] = {
		icon = "textures/property/chest-req.texture",
		desc = "储物箱需求: ",
		pos = 6,
	},
	["truck"] = {
		icon = "textures/property/delivery-truck.texture",
		desc = "运输车数量: ",
		pos = 7,
	},
	["truck_req"] = {
		icon = "textures/property/delivery-truck-req.texture",
		desc = "运输车需求: ",
		pos = 8,
	},
	["drone"] = {
		icon = "textures/property/drone.texture",
		desc = "无人机数量: ",
		pos = 9,
	},
	["drone_max"] = {
		icon = "textures/property/drone-max.texture",
		desc = "无人机最大数量: ",
		pos = 10,
	},
	["gas_speed"] = {
		icon = "textures/property/gas-speed.texture",
		desc = "气体速度: ",
		pos = 11,
	},
	["generate_power"] = {
		icon = "textures/property/generate-power.texture",
		desc = "发电功率: ",
		pos = 12,
	},
	["work_power"] = {
		icon = "textures/property/work-power.texture",
		desc = "工作功率: ",
		pos = 13,
	},
	["idle_power"] = {
		icon = "textures/property/idle-power.texture",
		desc = "工作功率: ",
		pos = 14,
	},
	["production_speed"] = {
		icon = "textures/property/production-speed.texture",
		desc = "生产速度: ",
		pos = 15,
	},
	["productivity_bonus"] = {
		icon = "textures/property/productivity-bonus.texture",
		desc = "产能加成: ",
		pos = 16,
	},
	["productivity_efficiency"] = {
		icon = "textures/property/productivity-efficiency.texture",
		desc = "生产效率: ",
		pos = 17,
	},
	["research_packs"] = {
		icon = "textures/property/research-packs.texture",
		desc = "研究瓶数量: ",
		pos = 18,
	},
	["research_speed"] = {
		icon = "textures/property/research-speed.texture",
		desc = "研究速度: ",
		pos = 19,
	},
	["research_time"] = {
		icon = "textures/property/research-time.texture",
		desc = "研究时间: ",
		pos = 20,
	},
	["temperature"] = {
		icon = "textures/property/temperature.texture",
		desc = "当前温度: ",
		pos = 21,
	},
	["temperature_max"] = {
		icon = "textures/property/temperature-max.texture",
		desc = "最高温度: ",
		pos = 22,
	},
}

-- for debug
for _, classify in ipairs {"in1","in2","in3","in4","out1","out2","out3"} do
	local t = {
		"fluidboxes_" .. classify .. "_volume",
		"fluidboxes_" .. classify .. "_capacity",
		"fluidboxes_" .. classify .. "_flow",
		"fluidboxes_" .. classify .. "_base_level",
		"fluidboxes_" .. classify .. "_height",
	}

	for _, name in ipairs(t) do
		property_list[name] = {
			icon = "textures/property/fluid-volume.texture",
			desc = ("%s: "):format(name):gsub("fluidboxes_", ""),
			value = ("$%s$"):format(name),
			pos = 3,
			debug = true,
		}
	end
end

return property_list