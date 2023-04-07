local guide = {
	{
        name = "",
		narrative = {
            {"哔哩..哔哗..已迫降在{/g 代号P4031}的星球。尚未发现任何生命迹象..(失望)", "textures/guide/guide-6.texture"},
            {"哔哩..哔哗..哔哩..启动大气分析协议中..P4031{/g 缺少氧气}..(失望)"},
            {"哔哩..哔哗..哔哩..启动地质分析协议中..P4031{/g 铁铝丰富}..(轻松)","textures/guide/guide-1.texture"},
            {"哔哩..哔哗..启动生存可靠性分析..{/color:4bd0ff 0.04565%}存活概率..(情绪表达跳过中)","textures/guide/guide-4.texture"},
    
        },
        narrative_end = {
            task = {
                "迫降火星",
            },
            guide_progress = 10,
        },
        prerequisites = {},
	},
	{
        name = "",
		narrative = {
            {"作为助理AI，我建议你立刻开始工作..哔哩..你的剩余生存时间理论上只有{/color:4bd0ff 348.26}地球小时..(担忧)", "textures/guide/guide-6.texture"},
            {"哔哩..发现{/g 建造中心}和{/g 建筑废墟}..哔哩..在{/color:4bd0ff 建造中心}中选择需待建建筑..哔哩..(期待)", "textures/guide/guide-2.texture"},
        },
        narrative_end = {
            pop_chapter = {"序章","迫降P4031"},
            task = {
                "采矿机调度",
            },
            guide_progress = 10,
        },
        prerequisites = {"迫降火星"},
	},


    {
        name = "",
		narrative = {
            {"哔哩..无人机真是听话的机器..请操作附近的{/color:4bd0ff 建造中心}建造{/g 采矿机}..(期待)", "textures/guide/guide-6.texture"},
        },
        narrative_end = {
            -- pop_chapter = {"第一阶段","物流网络"},
            guide_progress = 10,
            task = {
                "建造采矿机",
            }
        },
        prerequisites = {
            "采矿机调度",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..{/g 采矿机}顺利建造完毕..石矿采集技术可行性为{/color:4bd0ff 99.983%}..哔哩..(期待)", "textures/guide/guide-2.texture"},
            {"哔哩..将{/g 采矿机}放置在{/g 石矿}上方，碎石就可以被采矿机开采出来了..哔哩..(期待)", "textures/guide/guide-2.texture"},
        },
        narrative_end = {
            guide_progress = 10,
            task = {
                "石矿放置采矿机",
            }
        },
        prerequisites = {
            "建造采矿机",
        },
	},


    {
        name = "",
		narrative = {
            {"哔哩..目前采矿机处于{/r 断电状态}，无法正常工作..哔哩..哔哗..(失望)", "textures/guide/guide-6.texture"},
            {"哔哩..废墟中发现可用的{/g 电线杆设计图}，把它传送至{/color:4bd0ff 建造中心}。", "textures/guide/guide-6.texture"}, 
        },
        narrative_end = {
            guide_progress = 10,
            task = {
                "电线杆调度",
            }
        },
        prerequisites = {
            "石矿放置采矿机",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..请使用{/color:4bd0ff 建造中心}生产足够{/g 电线杆}..哔哩..哔哗..(期待)", "textures/guide/guide-3.texture"},
        },
        narrative_end = {
            guide_progress = 10,
            task = {
                "建造电线杆",
            }
        },
        prerequisites = {
            "电线杆调度",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..整个基地的{/color:4bd0ff 用电设施}都需要被{/g 电网}覆盖，否则它们将无法工作..哔哩(无奈）", "textures/guide/guide-6.texture"},
            {"{/color:4bd0ff 风力发电机}可产生电力..哔哩..在风力发电机附近放置{/g 电线杆}可以形成{/color:4bd0ff 电网}..哔哩(期待)", "textures/guide/guide-3.texture"},
            {"当电线杆之间出现{/r 红色电线}时则表示成功连接，在其覆盖{/color:4bd0ff 蓝色范围}内就会提供电能(兴奋)", "textures/guide/guide-3.texture"},
            {"{/g 电网}可以通过连接多个{/color:4bd0ff 电线杆}逐步扩散，它们所形成的{/g 电网}就能让用电设施工作了..哔哩(兴奋)", "textures/guide/guide-3.texture"},
        },
        narrative_end = {
            guide_progress = 10,
            task = {
                "放置电线杆",
            }
        },
        prerequisites = {
            "建造电线杆",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..采矿机顺利工作了，储藏石矿需要新的{/color:4bd0ff 无人机仓库}，请将{/g 无人机仓库设计图}送往{/color:4bd0ff 建造中心}..哔哩(期待)", "textures/guide/guide-3.texture"},
        },
        narrative_end = {
            guide_progress = 10,
            task = {
                "无人机仓库调度",
            }
        },
        prerequisites = {
            "放置电线杆",
        },
	},


    {
        name = "",
		narrative = {
            {"哔哩..{/color:4bd0ff 无人机}能运输指定货物，让我们用{/color:4bd0ff 建造中心}建造更多的{/g 无人机仓库}....(轻松)", "textures/guide/guide-1.texture"},
        },
        narrative_end = {
            guide_progress = 10,
            task = {
                "建造无人机仓库",
            }
        },
        prerequisites = {
            "无人机仓库调度",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..将新建的{/color:4bd0ff 无人机仓库}放置在{/g 采矿机}旁边，无人机就可以运输矿石了....(轻松)", "textures/guide/guide-1.texture"},
        },
        narrative_end = {
            guide_progress = 10,
            task = {
                "放置无人机仓库",
            }
        },
        prerequisites = {
            "建造无人机仓库",
        },
	},


    {
        name = "",
		narrative = {
            {"哔哩..矿物采集进展非常顺利，存活概率大幅提升至{/color:4bd0ff 0.3244%}..(期待)", "textures/guide/guide-2.texture"},
            {"哔哩..勤劳的{/color:4bd0ff 无人机}再次上线..在仓库中选择运输{/g 碎石}就可以开始工作了..哔哩(兴奋)", "textures/guide/guide-3.texture"},
            {"哔哩..让我们采集足够{/g 碎石}资源吧..哔哩(兴奋)", "textures/guide/guide-3.texture"},
        },
        narrative_end = {
            guide_progress = 10,
            task = {
                "生产碎石矿",
            }
        },
        prerequisites = {
            "放置无人机仓库",
        },
	},

    {
        name = "",
		narrative = {
            {"我们需要对这个星球进行全面的科学考察，让我们建造并放置一座{/g 科研中心}..哔哩..(期待)", "textures/guide/guide-2.texture"},
        },
        narrative_end = {
            guide_progress = 10,--10
            task = {
                "放置科研中心",
            }
        },
        prerequisites = {
            "生产碎石矿",
        },
	},
    -- {
    --     name = "guide-8",
	-- 	narrative = {
    --         {"哔哩..哔哩..矿物采集进展非常顺利，{/g 存活概率}大幅提升至0.3244%！(兴奋)", "textures/guide/guide-3.texture"},
    --         {"哔哩..指挥中心有{/g 制造舱}，可以生产简单物件..请使用制造舱生产几个{/g 地质科技包}..哔哩(期待)", "textures/guide/guide-2.texture"},
    --     },
    --     narrative_end = {
    --         guide_progress = 25,
    --         task = {
    --             "制造舱生产",
    --         }
    --     },
    --     prerequisites = {
    --         "转运铁矿石",
    --         "转运碎石矿",
    --     },
	-- },

    {
        name = "",
		narrative = {
            {"{/color:4bd0ff 科研中心}需要一些样本才可以开展深入研究..让我们采集一些{/g 地质科技包}吧(兴奋)", "textures/guide/guide-3.texture"},
        },
        narrative_end = {
            pop_chapter = {"第一章","自动生产"},
            guide_progress = 30,
            task = {
                "地质研究",
            }
        },
        prerequisites = {
            "放置科研中心",
        },
	},

    {
        name = "",
		narrative = {
            {"{/color:4bd0ff 组装机}已经就位,只要不断提供原料组装机就可以不断地自动化生产..哔哩..（期待)", "textures/guide/guide-3.texture"},
            {"在{/color:4bd0ff 组装机}的{/g 设置}里选择{/g 地质科技包1}进行批量生产吧..哔哩..（期待)", "textures/guide/guide-3.texture"},
        },
        narrative_end = {
            guide_progress = 30,
            task = {
                "科技包产线搭建",
            }
        },
        prerequisites = {
            "放置组装机",
        },
	},

    {
        name = "",
		narrative = {
            {"{/color:4bd0ff 石砖}是铺设{/color:4bd0ff 道路}的最佳材料..哔哩..哔哗..(期待)", "textures/guide/guide-2.texture"},
            {"让我们立即研究道路建造的工程方法,{/color:4bd0ff 道路}会帮助我们进行高效{/color:4bd0ff 物流}..哔哩..(兴奋)", "textures/guide/guide-3.texture"},
        },
        narrative_end = {
            guide_progress = 30,
            task = {
                "道路研究",
            }
        },
        prerequisites = {
            "生产石砖",
        },
	}, 

    {
        name = "",
		narrative = {
            {"{/color:4bd0ff 组装机}可以制造{/g 修路站设计图}，赶紧开动吧..哔哗..(期待)", "textures/guide/guide-2.texture"},
        },
        narrative_end = {
            guide_progress = 30,
            task = {
                "道路设计",
            }
        },
        prerequisites = {
            "道路研究",
        },
	},

    {
        name = "",
		narrative = {
            {"再将{/color:4bd0ff 修路站设计图}送入{/color:4bd0ff 建造中心}就可以开始建造{/g 修路站}了..哔哗..(期待)", "textures/guide/guide-2.texture"},
        },
        narrative_end = {
            guide_progress = 30,
            task = {
                "建造道路站",
            }
        },
        prerequisites = {
            "道路设计",
        },
	},

    {
        name = "",
		narrative = {
            {"我们需要以{/g 指挥中心}为起点修建一条通往{/g 铁矿}的{/color:4bd0ff 道路}..哔哗..(期待)", "textures/guide/guide-2.texture"},
            {"{/color:4bd0ff 道路}可以通行{/g 运输车辆},这样可以大大提高我们远程物流的效率..哔哗..(高兴)", "textures/guide/guide-2.texture"},
        },
        narrative_end = {
            guide_progress = 30,
            task = {
                "通向铁矿",
            }
        },
        prerequisites = {
            "放置修路站",
        },
	},

    {
        name = "",
		narrative = {
            {"是时候开采这个星球的新资源——{/color:4bd0ff 铁矿}了，让我们在铁矿上再放置一台{/g 采矿机}吧..哔哗..(期待)", "textures/guide/guide-2.texture"},
        },
        narrative_end = {
            guide_progress = 30,
            task = {
                "铁矿放置采矿机",
            }
        },
        prerequisites = {
            "生产运输车辆",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..哔哗..基地开始采集气液资源，{/g 管道}正是运输此类资源的关键..(兴奋)", "textures/guide/guide-3.texture"},
        },
        narrative_end = {
            guide_progress = 30,
            task = {
                "生产管道",
            }
        },
        prerequisites = {
            "管道系统1",
        },
	},

    {
        name = "",
		narrative = {
            {"合理的铺设管道让液体运输更加高效...哔哩..注意管道和机器液口的连接，耐心..和眼神..是关键(期待)", "textures/guide/guide-2.texture"},
        },
        narrative_end = {
            guide_progress = 30,
            task = {
            }
        },
        prerequisites = {
            "生产管道",
        },
	},

    {
        name = "",
		narrative = {
            {"我们具备了提取空气中有用气体的能力..哔哩..(兴奋)", "textures/guide/guide-2.texture"},
            {"很多稀有气体可以用于工业生产，让我们开始研究{/g 空气分离}吧..哔哩..哔哩(兴奋)", "textures/guide/guide-3.texture"},
        },
        narrative_end = {
            guide_progress = 30,
            task = {
            }
        },
        prerequisites = {
        },
	},

    {
        name = "",
		narrative = {
            {"{/g 化工厂}准备就绪，让我们正式进入化工生产..哔哩..哔哩..(兴奋）", "textures/guide/guide-3.texture"},
        },
        narrative_end = {
            pop_chapter = {"第二阶段","化工生产"},
            guide_progress = 30,
            task = {
            }
        },
        prerequisites = {
        },
	},

    {
        name = "",
		narrative = {
            {"{/g 塑料}可制造更多精密元件，掌握这种新材料，存活概率提升为{/color:4bd0ff 1.2923%}..哔哩(兴奋）", "textures/guide/guide-3.texture"},
        },
        narrative_end = {
            guide_progress = 30,
            task = {
            }
        },
        prerequisites = {
        },
	},

    {
        name = "",
		narrative = {
            {"终于可以研制机械装置进入自动化生产，这可以大大提高效率..哔哩..和放松你的手臂..哔哩(期待）", "textures/guide/guide-2.texture"},
        },
        narrative_end = {
            guide_progress = 30,
            task = {
            }
        },
        prerequisites = {
        },
	},

}

return guide