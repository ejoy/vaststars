local guide = {
	{
        name = "",
		narrative = {
            {"哔哩..航天飞机迫降{/g 代号P4031}星球。机体受重创已四分五裂..(失望)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
            -- {"哔哩..哔哗..哔哩..启动大气分析协议中..P4031{/g 缺少氧气}..(失望)"},
            -- {"哔哩..哔哗..哔哩..启动地质分析协议中..P4031{/g 石铁丰富}..(轻松)","/pkg/vaststars.resources/ui/textures/guide/guide-1.texture"},
            -- {"哔哩..哔哗..启动生存可靠性分析..存活概率为{/color:4bd0ff 0.04565%}..(失望)","/pkg/vaststars.resources/ui/textures/guide/guide-4.texture"},
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
            {"哔哩..开采星球资源需要大量物资，附近的{/color:4bd0ff 废墟堆}寻找{/g 有用物资}..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-2.texture"},
        },
        narrative_end = {
            pop_chapter = {"序章","迫降P4031"},
            task = {
                "地质研究",
            },
            guide_progress = 10,
        },
        prerequisites = {"迫降火星"},
	},

    -- {
    --     name = "",
	-- 	narrative = {
    --       -- {"哔哩..基地的{/color:4bd0ff 电网}尚未铺设，所以当前采矿机{/r 断电停工}..哔哩..哔哗..(失望)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
    --         {"哔哩..{/g 采矿机}放置在{/g 石矿}上方..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-1.texture"},
    --     },
    --     narrative_end = {
    --         guide_progress = 10,
    --         task = {
    --             "放置采矿机1",
    --         }
    --     },
    --     prerequisites = {
    --         "搜索废墟",
    --     },
	-- },

    -- {
    --     name = "",
	-- 	narrative = {
    --         {"哔哩..基地的{/color:4bd0ff 用电设施}都需要{/g 电力}驱动，否则它们将无法工作..哔哩(无奈）", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
    --         -- {"{/color:4bd0ff 风力发电机}可产生电力..哔哩..在其附近放置{/g 电线杆}可以形成{/color:4bd0ff 电网}..哔哩(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-3.texture"},
    --         -- {"当电线杆之间出现{/r 红色电线}时则表示成功连接，在其覆盖{/color:4bd0ff 蓝色范围}内就会提供电力(高兴)", "/pkg/vaststars.resources/ui/textures/guide/guide-3.texture"},
    --     },
    --     narrative_end = {
    --         guide_progress = 15,
    --         task = {
    --             "放置电线杆",
    --         }
    --     },
    --     prerequisites = {
    --         "放置采矿机1",
    --     },
	-- },

    -- {
    --     name = "",
	-- 	narrative = {
    --        -- {"哔哩..矿物采集进展非常顺利，存活概率大幅提升至{/color:4bd0ff 0.3244%}..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-2.texture"},
    --         {"哔哩..放置一座可以储存货物的{/color:4bd0ff 仓库}..哔哩(高兴)", "/pkg/vaststars.resources/ui/textures/guide/guide-3.texture"},
    --     },
    --     narrative_end = {
    --         guide_progress = 25,
    --         task = {
    --             "放置仓库",
    --         }
    --     },
    --     prerequisites = {
    --         "放置电线杆",
    --     },
	-- },

    -- {
    --     name = "",
	-- 	narrative = {
    --        -- {"哔哩..矿物采集进展非常顺利，存活概率大幅提升至{/color:4bd0ff 0.3244%}..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-2.texture"},
    --         {"哔哩..在{/color:4bd0ff 仓库I}中选择储存物品{/g 碎石}..哔哩(高兴)", "/pkg/vaststars.resources/ui/textures/guide/guide-3.texture"},
    --     },
    --     narrative_end = {
    --         guide_progress = 25,
    --         task = {
    --             "仓库设置1",
    --         }
    --     },
    --     prerequisites = {
    --         "放置仓库",
    --     },
	-- },

    -- {
    --     name = "",
	-- 	narrative = {
    --        -- {"哔哩..采矿机通电正常运转。石矿里{/color:4bd0ff 碎石}将被开采出来..哔哩(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-1.texture"},
    --         {"哔哩..现在我们需要修建{/g 无人机平台}从采矿机运送{/color:4bd0ff 碎石}到{/g 仓库}....(轻松)", "/pkg/vaststars.resources/ui/textures/guide/guide-1.texture"},
    --     },
    --     narrative_end = {
    --         guide_progress = 20,
    --         task = {
    --             "放置无人机平台",
    --         }
    --     },
    --     prerequisites = {
    --         "仓库设置1",
    --     },
	-- },



    -- {
    --     name = "",
	-- 	narrative = {
    --         {"哔哩..让我们采集足够{/g 碎石}资源吧..哔哩(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-1.texture"},
    --     },
    --     narrative_end = {
    --         guide_progress = 27,
    --         task = {
    --             "收集碎石",
    --         }
    --     },
    --     prerequisites = {
    --         "放置无人机平台",
    --     },
	-- },

    -- -- {
    -- --     name = "",
	-- -- 	narrative = {
    -- --         --{"哔哩..{/g 1座}无人机平台I最多容纳{/g 24块}碎石..(失望)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
    -- --         {"哔哩..要放置更多的{/color:4bd0ff 碎石}就需要更多的{/g 无人机平台I},尝试收集更多碎石吧..哔哩(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-1.texture"},
    -- --     },
    -- --     narrative_end = {
    -- --         guide_progress = 28,
    -- --         task = {
    -- --             "更多碎石",
    -- --         }
    -- --     },
    -- --     prerequisites = {
    -- --         "收集碎石",
    -- --     },
	-- -- },

	-- {
    --     name = "",
	-- 	narrative = {
    --       --  {"哔哩..{/color:4bd0ff 废墟堆}里获取{/g 采矿机},它可以帮助我们开采矿藏..哔哩..(兴奋)", "/pkg/vaststars.resources/ui/textures/guide/guide-3.texture"},
    --         {"哔哩..{/g 采矿机}放置在{/g 铁矿}上方，采矿机将开采铁矿资源..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-1.texture"},
    --     },
    --     narrative_end = {
    --         task = {
    --             "放置采矿机2",
    --         },
    --         guide_progress = 28,
    --     },
    --     prerequisites = {"收集碎石"},
	-- },

    -- {
    --     name = "",
	-- 	narrative = {
    --       --  {"哔哩..基地的{/color:4bd0ff 电网}尚未铺设，所以当前采矿机{/r 断电停工}..哔哩..哔哗..(失望)", "/pkg/vaststars.resources/ui/textures/guide/guide-6.texture"},
    --         {"哔哩..急需{/color:4bd0ff 供电设备}，请放置{/g 风力发电机}并放置在铁矿{/g 采矿机}周围。", "/pkg/vaststars.resources/ui/textures/guide/guide-1.texture"}, 
    --     },
    --     narrative_end = {
    --         guide_progress = 29,
    --         task = {
    --             "放置风力发电机",
    --         }
    --     },
    --     prerequisites = {
    --         "放置采矿机2",
    --     },
	-- },

    -- {
    --     name = "",
	-- 	narrative = {
    --        {"哔哩..使用采矿机挖掘6个{/g 铁矿石}..哔哩..哔哗..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-1.texture"},
    --     },
    --     narrative_end = {
    --         guide_progress = 29,
    --         task = {
    --             "收集铁矿石",
    --         }
    --     },
    --     prerequisites = {
    --         "放置风力发电机",
    --     },
	-- },

    -- {
    --     name = "",
	-- 	narrative = {
    --        {"哔哩..铁矿下方有一处铝矿,再使用采矿机挖掘6个{/g 铝矿石}..哔哩..哔哗..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-1.texture"},
    --     },
    --     narrative_end = {
    --         guide_progress = 29,
    --         task = {
    --             "收集铝矿石",
    --         }
    --     },
    --     prerequisites = {
    --         "收集铁矿石",
    --     },
	-- },

    -- {
    --     name = "",
	-- 	narrative = {
    --         {"资源充足可开展科学研究。请在{/color:4bd0ff 电网覆盖}范围中放置一座{/g 科研中心}..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-1.texture"},
    --     },
    --     narrative_end = {
    --         guide_progress = 29,--10
    --         task = {
    --             "放置科研中心",
    --         }
    --     },
    --     prerequisites = {
    --         "收集铝矿石",
    --     },
	-- },

    -- {
    --     name = "",
	-- 	narrative = {
    --         {"有了{/color:4bd0ff 科研中心}我们就可以从{/g 科研目标}里选择需要研究的对象(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-1.texture"},
    --     },
    --     narrative_end = {
    --         guide_progress = 30,--10
    --         task = {

    --         }
    --     },
    --     prerequisites = {
    --         "放置科研中心",
    --     },
	-- },

    -- {
    --     name = "",
	-- 	narrative = {
    --         {"现在{/color:4bd0ff 仓库}里可以选择接收{/g 地质科技包}(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-1.texture"},
    --     },
    --     narrative_end = {
    --         guide_progress = 30,--10
    --         task = {
    --             "仓库设置2",
    --         }
    --     },
    --     prerequisites = {
    --         "地质研究",
    --     },
	-- },

    {
        name = "",
		narrative = {
            {"使用组装机生产科研关键物品{/g 地质科技包}..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-1.texture"},
            --{"记得建造{/g 无人机平台I}来存储生产出来地{/g 地质科技包}..哔哩..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-1.texture"},
        },
        narrative_end = {
            pop_chapter = {"第一章","自动生产"},
            guide_progress = 35,--10
            task = {
                "石头处理1",
            }
        },
        prerequisites = {
            "地质研究",
        },
	},
    
    -- {
    --     name = "",
	-- 	narrative = {
    --        -- {"基地{/color:4bd0ff 东面}有未开发的{/g 铁矿}，前往开采铁矿需要更便捷物流方式..哔哩..哔哗..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-2.texture"},
    --         {"让我们尽快开发{/g 制铁工艺}..哔哗(高兴)", "/pkg/vaststars.resources/ui/textures/guide/guide-3.texture"},
    --     },
    --     narrative_end = {
    --         guide_progress = 49,
    --         task = {
    --             "铁矿熔炼",
    --         }
    --     },
    --     prerequisites = {
    --         "生产石砖",
    --     },
	-- },


    -- {
    --     name = "",
	-- 	narrative = {
    --         {"石头可以用于铺设{/g 公路}进而开展更便捷的物流,让我们立即修建{/g 砖石公路}吧..哔哗..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-1.texture"},
    --     },
    --     narrative_end = {
    --         guide_progress = 52,
    --         task = {
    --             "建造公路",
    --         }
    --     },
    --     prerequisites = {
    --         "公路研究",
    --     },
	-- },

    -- {
    --     name = "",
	-- 	narrative = {
    --         {"我们需要以{/g 指挥中心}为起点修建一条通往{/g 铁矿}的{/color:4bd0ff 道路}..哔哗..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-2.texture"},
    --         {"{/color:4bd0ff 道路}可以通行{/g 运输车辆},这样可以大大提高我们远程物流的效率..哔哗..(高兴)", "/pkg/vaststars.resources/ui/textures/guide/guide-2.texture"},
    --     },
    --     narrative_end = {
    --         guide_progress = 53,
    --         task = {
    --             "通向铁矿",
    --         }
    --     },
    --     prerequisites = {
    --         "建造公路",
    --     },
	-- },


    -- {
    --     name = "",
	-- 	narrative = {
    --         {"从指挥中心派遣{/g 运输车辆}..哔哗..(期待)", "/pkg/vaststars.resources/ui/textures/guide/guide-2.texture"},
    --     },
    --     narrative_end = {
    --         guide_progress = 53,
    --         task = {
    --             "物流网络",
    --         }
    --     },
    --     prerequisites = {
    --         "维修运输车辆",
    --     },
	-- },

    -- {
    --     name = "",
	-- 	narrative = {
    --         {"哔哩..哔哗..基地开始采集气液资源，{/g 管道}正是运输此类资源的关键..(高兴)", "/pkg/vaststars.resources/ui/textures/guide/guide-3.texture"},
    --     },
    --     narrative_end = {
    --         guide_progress = 56,
    --         task = {
    --             "生产管道",
    --         }
    --     },
    --     prerequisites = {
    --         "管道系统1",
    --     },
	-- },

    -- {
    --     name = "",
	-- 	narrative = {
    --         --{"我们具备了提取空气中有用气体的能力..哔哩..(高兴)", "/pkg/vaststars.resources/ui/textures/guide/guide-2.texture"},
    --         {"很多稀有气体可以用于工业生产，让我们开始研究{/g 空气分离}吧..哔哩..哔哩(高兴)", "/pkg/vaststars.resources/ui/textures/guide/guide-3.texture"},
    --     },
    --     narrative_end = {
    --         guide_progress = 58,
    --         task = {
    --             "空气分离工艺1",
    --         }
    --     },
    --     prerequisites = {
    --         "建筑维修4",
    --         "电解水",
    --     },
	-- },

    -- {
    --     name = "",
	-- 	narrative = {
    --         {"我们基地正在扩大,也随之带来更大的电力负荷,让我们放置{/color:4bd0ff 太阳能板}发电吧..哔哩(期待）", "/pkg/vaststars.resources/ui/textures/guide/guide-2.texture"},
    --     },
    --     narrative_end = {
    --         guide_progress = 59,
    --         task = {
    --             "放置太阳能板",
    --         }
    --     },
    --     prerequisites = {
    --         "碳处理1",
    --     },
	-- },


    {
        name = "",
		narrative = {
            {"让我们正式进入化工生产..哔哩..哔哩..(高兴）", "/pkg/vaststars.resources/ui/textures/guide/guide-3.texture"},
        },
        narrative_end = {
            pop_chapter = {"第二章","化工生产"},
            guide_progress = 60,
            task = {
            }
        },
        prerequisites = {
            "碳处理1",
        },
	},

    -- {
    --     name = "",
	-- 	narrative = {
    --         {"{/g 塑料}可制造更多精密元件，掌握这种新材料，存活概率提升为{/color:4bd0ff 1.2923%}..哔哩(高兴）", "/pkg/vaststars.resources/ui/textures/guide/guide-3.texture"},
    --     },
    --     narrative_end = {
    --         guide_progress = 61,
    --         task = {
    --         }
    --     },
    --     prerequisites = {
    --         "生产塑料",
    --     },
	-- },

    -- {
    --     name = "",
	-- 	narrative = {
    --         {"终于可以研制机械装置进入自动化生产，这可以大大提高效率..哔哩..和放松你的手臂..哔哩(期待）", "/pkg/vaststars.resources/ui/textures/guide/guide-2.texture"},
    --     },
    --     narrative_end = {
    --         guide_progress = 62,
    --         task = {
    --         }
    --     },
    --     prerequisites = {
    --         "电磁学1",
    --     },
	-- },

}

return guide