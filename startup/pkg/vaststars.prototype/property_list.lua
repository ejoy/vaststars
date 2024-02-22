local property_list = {
	["health"] = {
		-- icon = "/pkg/vaststars.resources/ui/textures/property/building-health.texture",
		desc = "建筑生命",
		-- value = "$health$/$total_health$",
		pos = 1,
	},
	["fluid_name"] = {
		-- icon = "/pkg/vaststars.resources/ui/textures/property/fluid-type.texture",
		desc = "流体类型",
		value = "$fluid_name$",
		pos = 2,
	},
	["fluid_volume"] = {
		-- icon = "/pkg/vaststars.resources/ui/textures/property/fluid-volume.texture",
		desc = "流体容量",
		value = "$fluid_volume$/$fluid_capacity$",
		pos = 3,
	},
	["fluid_rate"] = {
		-- icon = "/pkg/vaststars.resources/ui/textures/property/fluid-rate.texture",
		desc = "流体流速",
		value = "$fluid_flow$",
		pos = 4,
	},
	["chest_capacity"] = {
		-- icon = "/pkg/vaststars.resources/ui/textures/property/chest-capacity.texture",
		desc = "储存容量",
		value = "$slots$",
		pos = 5,
	},
	["chest_req"] = {
		-- icon = "/pkg/vaststars.resources/ui/textures/property/chest-req.texture",
		desc = "货物需求",
		pos = 6,
	},
	["drone"] = {
		-- icon = "/pkg/vaststars.resources/ui/textures/property/drone.texture",
		desc = "无人机数量",
		value = "$drone_count$",
		pos = 9,
	},
	["drone_max"] = {
		-- icon = "/pkg/vaststars.resources/ui/textures/property/drone-max.texture",
		desc = "无人机最大数量",
		pos = 10,
	},
	["gas_speed"] = {
		-- icon = "/pkg/vaststars.resources/ui/textures/property/gas-speed.texture",
		desc = "气体速度",
		pos = 11,
	},
	["generate_power"] = {
		-- icon = "/pkg/vaststars.resources/ui/textures/property/generate-power.texture",
		desc = "发电功率",
		value = "$power$",
		pos = 12,
	},
	["work_power"] = {
		-- icon = "/pkg/vaststars.resources/ui/textures/property/work-power.texture",
		desc = "工作功率",
		value = "$power$",
		pos = 13,
	},
	["charge_power"] = {
		-- icon = "/pkg/vaststars.resources/ui/textures/property/idle-power.texture",
		desc = "充电功率",
		value = "$charge_power$",
		pos = 15,
	},
	["charge_energy"] = {
		-- icon = "/pkg/vaststars.resources/ui/textures/property/idle-power.texture",
		desc = "蓄电电量",
		value = "$capacitance$",
		pos = 16,
	},
	["production_speed"] = {
		-- icon = "/pkg/vaststars.resources/ui/textures/property/production-speed.texture",
		desc = "生产速度",
		value = "$speed$",
		pos = 17,
	},
	["productivity_bonus"] = {
		-- icon = "/pkg/vaststars.resources/ui/textures/property/productivity-bonus.texture",
		desc = "产能加成",
		pos = 18,
	},
	["productivity_efficiency"] = {
		-- icon = "/pkg/vaststars.resources/ui/textures/property/productivity-efficiency.texture",
		desc = "生产效率",
		pos = 19,
	},
	["research_packs"] = {
		-- icon = "/pkg/vaststars.resources/ui/textures/property/research-packs.texture",
		desc = "研究瓶数量",
		pos = 20,
	},
	["research_speed"] = {
		-- icon = "/pkg/vaststars.resources/ui/textures/property/research-speed.texture",
		desc = "研究速度",
		value = "$laboratory.speed$",
		pos = 21,
	},
	["research_time"] = {
		-- icon = "/pkg/vaststars.resources/ui/textures/property/research-time.texture",
		desc = "研究时间",
		pos = 22,
	},
	["temperature"] = {
		-- icon = "/pkg/vaststars.resources/ui/textures/property/temperature.texture",
		desc = "当前温度",
		pos = 23,
	},
	["temperature_max"] = {
		-- icon = "/pkg/vaststars.resources/ui/textures/property/temperature-max.texture",
		desc = "最高温度",
		pos = 24,
	},
	["mine_deposit"] = {
		-- icon = "/pkg/vaststars.resources/ui/textures/property/mine-deposit.texture",
		desc = "矿物储量",
		pos = 27,
	},
	["mine_type"] = {
		-- icon = "/pkg/vaststars.resources/ui/textures/property/mine-type.texture",
		desc = "矿物类型",
		pos = 28,
	},
	["drone_count"] = {
		-- icon = "/pkg/vaststars.resources/ui/textures/property/drone.texture",
		desc = "无人机数量",
		value = "$drone_count$",
		pos = 29,
	},
	["pollution"] = {
		-- icon = "/pkg/vaststars.resources/ui/textures/property/drone.texture",
		desc = "污染排放",
		value = "$pollution$",
		pos = 30,
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
			-- icon = "/pkg/vaststars.resources/ui/textures/property/fluid-volume.texture",
			desc = ("%s: "):format(name):gsub("fluidboxes_", ""),
			value = ("$%s$"):format(name),
			pos = 3,
			debug = true,
		}
	end
end

property_list.converter = {}

property_list.converter["fluid_volume"] = function(v)
	return string.format("%.1f", v)
end

property_list.converter["fluid_capacity"] = function(v)
	return string.format("%d", math.floor(v))
end

for _, classify in ipairs {"in1","in2","in3","in4","out1","out2","out3"} do
	property_list.converter["fluidboxes_" .. classify .. "_volume"] = function(v)
		return string.format("%.1f", v)
	end

	property_list.converter["fluidboxes_" .. classify .. "_capacity"] = function(v)
		return string.format("%d", math.floor(v))
	end
end
return property_list