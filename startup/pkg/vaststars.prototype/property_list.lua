local property_list = {
	["health"] = {
		icon = "textures/property/building-health.texture",
		desc = "建筑生命",
		-- value = "$health$/$total_health$",
		pos = 1,
	},
	["fluid_name"] = {
		icon = "textures/property/fluid-type.texture",
		desc = "液体类型",
		value = "$fluid_name$",
		pos = 2,
	},
	["fluid_volume"] = {
		icon = "textures/property/fluid-volume.texture",
		desc = "液体容量",
		value = "$fluid_volume$/$fluid_capacity$",
		pos = 3,
	},
	["fluid_rate"] = {
		icon = "textures/property/fluid-rate.texture",
		desc = "液体流速",
		value = "$fluid_flow$",
		pos = 4,
	},
	["chest_capacity"] = {
		icon = "textures/property/chest-capacity.texture",
		desc = "储存容量",
		value = "$slots$",
		pos = 5,
	},
	["chest_req"] = {
		icon = "textures/property/chest-req.texture",
		desc = "货物需求",
		pos = 6,
	},
	["truck"] = {
		icon = "textures/property/delivery-truck.texture",
		desc = "运输车数量",
		pos = 7,
	},
	["truck_req"] = {
		icon = "textures/property/delivery-truck-req.texture",
		desc = "运输车需求",
		pos = 8,
	},
	["drone"] = {
		icon = "textures/property/drone.texture",
		desc = "无人机数量",
		pos = 9,
	},
	["drone_max"] = {
		icon = "textures/property/drone-max.texture",
		desc = "无人机最大数量",
		pos = 10,
	},
	["gas_speed"] = {
		icon = "textures/property/gas-speed.texture",
		desc = "气体速度",
		pos = 11,
	},
	["generate_power"] = {
		icon = "textures/property/generate-power.texture",
		desc = "发电功率",
		value = "$power$",
		pos = 12,
	},
	["work_power"] = {
		icon = "textures/property/work-power.texture",
		desc = "工作功率",
		value = "$power$",
		pos = 13,
	},
	["charge_power"] = {
		icon = "textures/property/idle-power.texture",
		desc = "充电功率",
		value = "$charge_power$",
		pos = 15,
	},
	["charge_energy"] = {
		icon = "textures/property/idle-power.texture",
		desc = "蓄电电量",
		value = "$capacitance$",
		pos = 16,
	},
	["production_speed"] = {
		icon = "textures/property/production-speed.texture",
		desc = "生产速度",
		value = "$speed$",
		pos = 17,
	},
	["productivity_bonus"] = {
		icon = "textures/property/productivity-bonus.texture",
		desc = "产能加成",
		pos = 18,
	},
	["productivity_efficiency"] = {
		icon = "textures/property/productivity-efficiency.texture",
		desc = "生产效率",
		pos = 19,
	},
	["research_packs"] = {
		icon = "textures/property/research-packs.texture",
		desc = "研究瓶数量",
		pos = 20,
	},
	["research_speed"] = {
		icon = "textures/property/research-speed.texture",
		desc = "研究速度",
		value = "$laboratory.speed$",
		pos = 21,
	},
	["research_time"] = {
		icon = "textures/property/research-time.texture",
		desc = "研究时间",
		pos = 22,
	},
	["temperature"] = {
		icon = "textures/property/temperature.texture",
		desc = "当前温度",
		pos = 23,
	},
	["temperature_max"] = {
		icon = "textures/property/temperature-max.texture",
		desc = "最高温度",
		pos = 24,
	},
	["power_supply_area"] = {
		icon = "textures/property/supply-area.texture",
		desc = "覆盖范围",
		value = "$power_supply_area$",
		pos = 25,
	},
	["power_supply_distance"] = {
		icon = "textures/property/supply-distance.texture",
		desc = "连接距离",
		value = "$power_supply_distance$",
		pos = 26,
	},
	["mine_deposit"] = {
		icon = "textures/property/mine-deposit.texture",
		desc = "矿物储量",
		pos = 27,
	},
	["mine_type"] = {
		icon = "textures/property/mine-type.texture",
		desc = "矿物类型",
		pos = 28,
	},
	["drone_count"] = {
		icon = "textures/property/drone.texture",
		desc = "无人机数量",
		value = "$drone_count$",
		pos = 29,
	},
	["weights"] = {
		icon = "textures/property/delivery-truck-req.texture",
		desc = "优先级",
		value = "$weights$",
		pos = 30,
	},
	["maxlorry"] = {
		icon = "textures/property/delivery-truck-req.texture",
		desc = "需求车辆",
		value = "$maxlorry$",
		pos = 30,
	},
	["lorry"] = {
		icon = "textures/property/delivery-truck.texture",
		desc = "响应车辆",
		value = "$lorry$",
		pos = 31,
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