local guide = {
	{
        name = "",
		narrative = {
            {"哔哩..航天飞机迫降{/g 代号P4031}星球。机体受重创已四分五裂..(失望)", "textures/guide/guide-6.texture"},
            {"哔哩..哔哗..哔哩..启动大气分析协议中..P4031{/g 缺少氧气}..(失望)"},
            {"哔哩..哔哗..哔哩..启动地质分析协议中..P4031{/g 石铁丰富}..(轻松)","textures/guide/guide-1.texture"},
            {"哔哩..哔哗..启动生存可靠性分析..存活概率为{/color:4bd0ff 0.04565%}..(失望)","textures/guide/guide-4.texture"},
        },
        narrative_end = {
            task = {
                "迫降火星",
            },
            guide_progress = 5,
        },
        prerequisites = {},
	},
	{
        name = "",
		narrative = {
            {"哔哩..开采星球资源需要工具，附近的{/color:4bd0ff 建材箱}寻找{/g 采矿机}..哔哩..(期待)", "textures/guide/guide-2.texture"},
            {"哔哩..{/g 采矿机}放置在{/g 石矿}上方，采矿机将开采石矿资源..哔哩..(期待)", "textures/guide/guide-1.texture"},
        },
        narrative_end = {
            pop_chapter = {"序章","迫降P4031"},
            task = {
                "放置采矿机",
            },
            guide_progress = 5,
        },
        prerequisites = {"迫降火星"},
	},

    {
        name = "",
		narrative = {
            {"哔哩..基地的{/color:4bd0ff 电网}尚未铺设，所以当前采矿机{/r 断电停工}..哔哩..哔哗..(失望)", "textures/guide/guide-6.texture"},
            {"哔哩..急需{/color:4bd0ff 供电设备}，请在周边{/color:4bd0ff 建材箱}选择{/g 风力发电机}并放置在{/g 采矿机}周围。", "textures/guide/guide-1.texture"}, 
        },
        narrative_end = {
            guide_progress = 10,
            task = {
                "放置风力发电机",
            }
        },
        prerequisites = {
            "放置采矿机",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..基地的{/color:4bd0ff 用电设施}都需要{/g 电力}驱动，否则它们将无法工作..哔哩(无奈）", "textures/guide/guide-6.texture"},
            {"{/color:4bd0ff 风力发电机}可产生电力..哔哩..在其附近放置{/g 电线杆}可以形成{/color:4bd0ff 电网}..哔哩(期待)", "textures/guide/guide-3.texture"},
            {"当电线杆之间出现{/r 红色电线}时则表示成功连接，在其覆盖{/color:4bd0ff 蓝色范围}内就会提供电力(高兴)", "textures/guide/guide-3.texture"},
        },
        narrative_end = {
            guide_progress = 15,
            task = {
                "放置电线杆",
            }
        },
        prerequisites = {
            "放置风力发电机",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..采矿机通电正常运转。石矿里{/color:4bd0ff 碎石}将被开采出来..哔哩(期待)", "textures/guide/guide-1.texture"},
            {"哔哩..{/color:4bd0ff 碎石}存放需要仓库，{/color:4bd0ff 建材箱}里的{/g 无人机仓库I}正好适合....(轻松)", "textures/guide/guide-1.texture"},
        },
        narrative_end = {
            guide_progress = 20,
            task = {
                "放置无人机仓库",
            }
        },
        prerequisites = {
            "放置电线杆",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..矿物采集进展非常顺利，存活概率大幅提升至{/color:4bd0ff 0.3244%}..(期待)", "textures/guide/guide-2.texture"},
            {"哔哩..在{/color:4bd0ff 无人机仓库I}中选择储存{/g 碎石}，无人机就会自动搬运物资了..哔哩(高兴)", "textures/guide/guide-3.texture"},
        },
        narrative_end = {
            guide_progress = 25,
            task = {
                "无人机仓库设置",
            }
        },
        prerequisites = {
            "放置无人机仓库",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..让我们采集足够{/g 碎石}资源吧..哔哩(期待)", "textures/guide/guide-1.texture"},
        },
        narrative_end = {
            guide_progress = 27,
            task = {
                "收集碎石",
            }
        },
        prerequisites = {
            "无人机仓库设置",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..{/g 1座}无人机仓库I最多容纳{/g 12块}碎石..(失望)", "textures/guide/guide-6.texture"},
            {"哔哩..要放置更多的{/color:4bd0ff 碎石}就需要更多的{/g 无人机仓库I},尝试收集更多碎石吧..哔哩(期待)", "textures/guide/guide-1.texture"},
        },
        narrative_end = {
            guide_progress = 28,
            task = {
                "更多碎石",
            }
        },
        prerequisites = {
            "收集碎石",
        },
	},

    {
        name = "",
		narrative = {
            {"资源充足可开展科学研究。请在{/color:4bd0ff 电网覆盖}范围中放置一座{/g 科研中心}..哔哩..(期待)", "textures/guide/guide-1.texture"},
        },
        narrative_end = {
            guide_progress = 29,--10
            task = {
                "放置科研中心",
            }
        },
        prerequisites = {
            "更多碎石",
        },
	},

    {
        name = "",
		narrative = {
            {"有了{/color:4bd0ff 科研中心}我们就可以从{/g 科研目标}里选择需要研究的对象(期待)", "textures/guide/guide-1.texture"},
        },
        narrative_end = {
            guide_progress = 30,--10
            task = {

            }
        },
        prerequisites = {
            "放置科研中心",
        },
	},

    {
        name = "",
		narrative = {
            {"在组装机附近的{/color:4bd0ff 无人机仓库I}选择物品{/g 地质科技包}后，无人机就可以开始搬运了..哔哩..(期待)", "textures/guide/guide-1.texture"},
            {"记得建造{/g 无人机仓库I}来存储生产出来地{/g 地质科技包}..哔哩..(期待)", "textures/guide/guide-1.texture"},
        },
        narrative_end = {
            pop_chapter = {"第一章","自动生产"},
            guide_progress = 35,--10
            task = {
                "组装机生产",
            }
        },
        prerequisites = {
            "放置组装机",
        },
	},
    -- {
    --     name = "",
	-- 	narrative = {
    --         {"哔哩..我忘记基地的{/color:4bd0ff 电网}尚未铺设，所以当前采矿机{/r 断电停工}..哔哩..哔哗..(失望)", "textures/guide/guide-6.texture"},
    --         {"哔哩..我们急需{/color:4bd0ff 电线杆}传输电力，请在周边{/color:4bd0ff 建材箱}选择{/g 铁制电线杆}。", "textures/guide/guide-1.texture"}, 
    --     },
    --     narrative_end = {
    --         guide_progress = 25,
    --         task = {
    --             "放置电线杆",
    --         }
    --     },
    --     prerequisites = {
    --         "放置风力发电机",
    --     },
	-- },


    -- {
    --     name = "",
	-- 	narrative = {
    --         {"哔哩..建造采矿机需要{/g 采矿机框架}..探测到{/color:4bd0ff 四处废墟}有残留物资..(期待)", "textures/guide/guide-1.texture"},
    --         {"哔哩..使用{/color:4bd0ff 遥感传送仪}可以{/g 远程传送}物资到目的地..(高兴)", "textures/guide/guide-3.texture"},
    --         {"哔哩..发现{/g 机尾残骸}有所需材料，请前往选择{/g 传送设置}进入准备传送状态..(期待)", "textures/guide/guide-1.texture"},
    --     },
    --     narrative_end = {
    --         guide_progress = 10,
    --         task = {
    --             "机尾残骸传送",
    --         }
    --     },
    --     prerequisites = {
    --         "采矿机打印预备",
    --     },
	-- },

    -- {
    --     name = "",
	-- 	narrative = {
    --         {"哔哩..{/g 机尾残骸}上方笼罩{/color:4bd0ff 蓝色光晕}表明传送准备就绪..(开心)", "textures/guide/guide-2.texture"},
    --         {"哔哩..让我们进入{/color:4bd0ff 建造中心}选择{/g 传送启动}接收物资吧..(高兴)", "textures/guide/guide-3.texture"},
    --     },
    --     narrative_end = {
    --         guide_progress = 15,
    --         task = {
    --             "采矿机传送接收",
    --         }
    --     },
    --     prerequisites = {
    --         "机尾残骸传送",
    --     },
	-- },

    -- {
    --     name = "",
	-- 	narrative = {
    --         {"哔哩..{/color:4bd0ff 采矿机框架}已经被成功传送至{/g 建造中心}..(高兴)", "textures/guide/guide-3.texture"},
    --         {"哔哩..{/g 采矿机}在{/color:4bd0ff 建造中心}里开始打印了。左侧栏下方显示打印{/color:4bd0ff 需求和进度}..哔哩..(期待)", "textures/guide/guide-1.texture"},
    --     },
    --     narrative_end = {
    --         guide_progress = 20,
    --         task = {
    --             "建造采矿机",
    --         }
    --     },
    --     prerequisites = {
    --         "采矿机传送接收",
    --     },
	-- },

    -- {
    --     name = "",
	-- 	narrative = {
    --         {"哔哩..{/g 采矿机}顺利建造完毕..石矿采集技术可行性为{/color:4bd0ff 99.983%}..哔哩..(高兴)", "textures/guide/guide-3.texture"},
    --         {"哔哩..将{/g 采矿机}放置在{/g 石矿}上方，采矿机就可以开采矿区资源{/color:4bd0ff 碎石}..哔哩..(期待)", "textures/guide/guide-1.texture"},
    --     },
    --     narrative_end = {
    --         guide_progress = 25,
    --         task = {
    --             "石矿放置采矿机",
    --         }
    --     },
    --     prerequisites = {
    --         "建造采矿机",
    --     },
	-- },


    -- {
    --     name = "",
	-- 	narrative = {
    --         {"哔哩..目前采矿机处于{/r 断电状态}，无法正常工作..哔哩..哔哗..(失望)", "textures/guide/guide-6.texture"},
    --         {"哔哩..我们急需{/color:4bd0ff 电线杆}传输电力，请在{/color:4bd0ff 建造中心}选择{/g 电线杆打印}。", "textures/guide/guide-1.texture"}, 
    --     },
    --     narrative_end = {
    --         guide_progress = 25,
    --         task = {
    --             "电线杆打印预备",
    --         }
    --     },
    --     prerequisites = {
    --         "石矿放置采矿机",
    --     },
	-- },

    -- {
    --     name = "",
	-- 	narrative = {
    --         {"哔哩..在{/color:4bd0ff 机翼残骸}发现{/g 电线杆框架}，前往该处进行{/g 传送设置}..哔哩..哔哗..(期望)", "textures/guide/guide-1.texture"},
    --     },
    --     narrative_end = {
    --         guide_progress = 25,
    --         task = {
    --             "机翼残骸传送",
    --         }
    --     },
    --     prerequisites = {
    --         "电线杆打印预备",
    --     },
	-- },

    -- {
    --     name = "",
	-- 	narrative = {
    --         {"哔哩..通常情况下我们需要寻找{/color:4bd0ff 不同的建筑}进行{/g 传送设置}..哔哩..（期待）", "textures/guide/guide-1.texture"}, 
    --         {"哔哩..选择{/g 传送启动}让{/color:4bd0ff 建造中心}接收{/color:4bd0ff 电线杆框架}..哔哩..（期待）", "textures/guide/guide-1.texture"},
    --     },
    --     narrative_end = {
    --         guide_progress = 26,
    --         task = {
    --             "电线杆传送接收",
    --         }
    --     },
    --     prerequisites = {
    --         "机翼残骸传送",
    --     },
	-- },

    -- {
    --     name = "",
	-- 	narrative = {
    --         {"哔哩..请使用{/color:4bd0ff 建造中心}生产尽可能多的{/g 电线杆}..哔哩..哔哗..(期待)", "textures/guide/guide-1.texture"},
    --     },
    --     narrative_end = {
    --         guide_progress = 27,
    --         task = {
    --             "建造电线杆",
    --         }
    --     },
    --     prerequisites = {
    --         "电线杆传送接收",
    --     },
	-- },

    -- {
    --     name = "",
	-- 	narrative = {
    --         {"哔哩..基地的{/color:4bd0ff 用电设施}都需要{/g 电力}驱动，否则它们将无法工作..哔哩(无奈）", "textures/guide/guide-6.texture"},
    --         {"{/color:4bd0ff 风力发电机}可产生电力..哔哩..在其附近放置{/g 电线杆}可以形成{/color:4bd0ff 电网}..哔哩(期待)", "textures/guide/guide-3.texture"},
    --         {"当电线杆之间出现{/r 红色电线}时则表示成功连接，在其覆盖{/color:4bd0ff 蓝色范围}内就会提供电力(高兴)", "textures/guide/guide-3.texture"},
    --     },
    --     narrative_end = {
    --         guide_progress = 30,
    --         task = {
    --             "放置电线杆",
    --         }
    --     },
    --     prerequisites = {
    --         "建造电线杆",
    --     },
	-- },

    -- {
    --     name = "",
	-- 	narrative = {
    --         {"哔哩..采矿机顺利工作了，储藏碎石需要新的{/color:4bd0ff 无人机仓库I}，请将{/g 无人机仓库I框架}送往{/color:4bd0ff 建造中心}..哔哩(期待)", "textures/guide/guide-1.texture"},
    --     },
    --     narrative_end = {
    --         guide_progress = 35,
    --         task = {
    --             "无人机仓库I打印预备",
    --         }
    --     },
    --     prerequisites = {
    --         "放置电线杆",
    --     },
	-- },


    -- {
    --     name = "",
	-- 	narrative = {
    --         {"哔哩..{/g 机头残骸}发现所需{/color:4bd0ff 无人机框架}，让我们开始{/g 传送设置}吧....(期待)", "textures/guide/guide-1.texture"},
    --     },
    --     narrative_end = {
    --         guide_progress = 35,
    --         task = {
    --             "机头残骸传送",
    --         }
    --     },
    --     prerequisites = {
    --         "无人机仓库I打印预备",
    --     },
	-- },

    -- {
    --     name = "",
	-- 	narrative = {
    --         {"哔哩..再次使用{/color:4bd0ff 建造中心}里的{/g 传送启动}接收{/color:4bd0ff 框架}....(期待)", "textures/guide/guide-1.texture"},
    --     },
    --     narrative_end = {
    --         guide_progress = 35,
    --         task = {
    --             "无人机仓库I传送接收",
    --         }
    --     },
    --     prerequisites = {
    --         "机头残骸传送",
    --     },
	-- },

    -- {
    --     name = "",
	-- 	narrative = {
    --         {"哔哩..建造{/color:4bd0ff 无人机仓库I}还需要额外资源{/g 碎石}....(期待)", "textures/guide/guide-1.texture"},
    --         {"哔哩..{/color:4bd0ff 采矿机}正好开采出需要的{/g 碎石}..请前往{/color:4bd0ff 采矿机}进行{/g 传送设置}..(期待)", "textures/guide/guide-1.texture"},
    --     },
    --     narrative_end = {
    --         guide_progress = 36,
    --         task = {
    --             "采矿机传送",
    --         }
    --     },
    --     prerequisites = {
    --         "无人机仓库I传送接收",
    --     },
	-- },

    -- {
    --     name = "",
	-- 	narrative = {
    --         {"哔哩..使用{/color:4bd0ff 建造中心}里的{/g 传送启动}接收{/color:4bd0ff 碎石}....(期待)", "textures/guide/guide-1.texture"},
    --     },
    --     narrative_end = {
    --         guide_progress = 37,
    --         task = {
    --             "碎石传送接收",
    --         }
    --     },
    --     prerequisites = {
    --         "采矿机传送",
    --     },
	-- },

    -- {
    --     name = "",
	-- 	narrative = {
    --         {"哔哩..我们终于将{/g 两种原料}传送了{/color:4bd0ff 指挥中心}..哔哩..(期待)", "textures/guide/guide-1.texture"},
    --         {"哔哩..让我们开始建造第一个{/g 无人机仓库I}..哔哩..(期待)", "textures/guide/guide-1.texture"},
    --     },
    --     narrative_end = {
    --         guide_progress = 38,
    --         task = {
    --             "建造无人机仓库I",
    --         }
    --     },
    --     prerequisites = {
    --         "碎石传送接收",
    --     },
	-- },

    -- {
    --     name = "",
	-- 	narrative = {
    --         {"哔哩..将新建的{/color:4bd0ff 无人机仓库I}放置在{/g 采矿机}旁边，让无人机仓库I储存{/color:4bd0ff 碎石}....(轻松)", "textures/guide/guide-1.texture"},
    --     },
    --     narrative_end = {
    --         guide_progress = 39,
    --         task = {
    --             "放置无人机仓库I",
    --         }
    --     },
    --     prerequisites = {
    --         "建造无人机仓库I",
    --     },
	-- },


    -- {
    --     name = "",
	-- 	narrative = {
    --         {"哔哩..矿物采集进展非常顺利，存活概率大幅提升至{/color:4bd0ff 0.3244%}..(期待)", "textures/guide/guide-2.texture"},
    --         {"哔哩..在{/color:4bd0ff 无人机仓库I}中选择储存{/g 碎石}，无人机就会自动搬运物资了..哔哩(高兴)", "textures/guide/guide-3.texture"},
    --     },
    --     narrative_end = {
    --         guide_progress = 40,
    --         task = {
    --             "无人机仓库I设置",
    --         }
    --     },
    --     prerequisites = {
    --         "放置无人机仓库I",
    --     },
	-- },


    -- {
    --     name = "",
	-- 	narrative = {
    --         {"哔哩..让我们采集足够{/g 碎石}资源吧..哔哩(期待)", "textures/guide/guide-1.texture"},
    --     },
    --     narrative_end = {
    --         guide_progress = 41,
    --         task = {
    --             "收集碎石矿",
    --         }
    --     },
    --     prerequisites = {
    --         "无人机仓库I设置",
    --     },
	-- },

    -- {
    --     name = "",
	-- 	narrative = {
    --         {"哔哩..我们可以尝试在{/color:4bd0ff 无人机仓库I}里进行{/g 传送设置}..(期待)", "textures/guide/guide-2.texture"},
    --     },
    --     narrative_end = {
    --         guide_progress = 42,
    --         task = {
    --             "无人机仓库I传送",
    --         }
    --     },
    --     prerequisites = {
    --         "收集碎石矿",
    --     },
	-- },

    -- {
    --     name = "",
	-- 	narrative = {
    --         {"哔哩..我们采集了足够多的碎石，可以建造更多的{/g 无人机仓库I}..(期待)", "textures/guide/guide-2.texture"},
    --     },
    --     narrative_end = {
    --         guide_progress = 43,
    --         task = {
    --             "更多无人机仓库I",
    --         }
    --     },
    --     prerequisites = {
    --         "无人机仓库I传送",
    --     },
	-- },

    -- {
    --     name = "",
	-- 	narrative = {
    --         {"哔哩..储藏{/color:4bd0ff 相同物品}的{/g 无人机仓库I}在足够近的距离可相互传递物品..(期待)", "textures/guide/guide-2.texture"},
    --         {"哔哩..需要放置更多的{/g 无人机仓库I}，记得设置存储{/color:4bd0ff 物品类型}..哔哩..(期待)", "textures/guide/guide-2.texture"},
    --     },
    --     narrative_end = {
    --         guide_progress = 44,--10
    --         task = {
    --             "第二个无人机仓库I",
    --         }
    --     },
    --     prerequisites = {
    --         "更多无人机仓库I",
    --     },
	-- },

    -- {
    --     name = "",
	-- 	narrative = {
    --         {"让我们把新{/color:4bd0ff 无人机仓库I}储存类型也设置为{/g 碎石}..哔哩..(期待)", "textures/guide/guide-1.texture"},
    --     },
    --     narrative_end = {
    --         guide_progress = 45,--10
    --         task = {
    --             "仓库碎石设置",
    --         }
    --     },
    --     prerequisites = {
    --         "第二个无人机仓库I",
    --     },
	-- },

    -- {
    --     name = "",
	-- 	narrative = {
    --         {"我们需要对这个星球进行全面的科学考察，让我们建造一座{/g 科研中心}..哔哩..(期待)", "textures/guide/guide-1.texture"},
    --         {"{/color:4bd0ff 科研中心框架}所在废墟已经被标注了，传送{/color:4bd0ff 碎石}可前往{/g 无人机仓库I}..哔哩..(期待)", "textures/guide/guide-1.texture"},
    --     },
    --     narrative_end = {
    --         guide_progress = 46,--10
    --         task = {
    --             "建造科研中心",
    --         }
    --     },
    --     prerequisites = {
    --         "仓库碎石设置",
    --     },
	-- },

    -- {
    --     name = "",
	-- 	narrative = {
    --         {"终于大功告成，让我们放置{/g 科研中心}到{/color:4bd0ff 电网覆盖}范围中吧..哔哩..(期待)", "textures/guide/guide-1.texture"},
    --     },
    --     narrative_end = {
    --         guide_progress = 47,--10
    --         task = {
    --             "放置科研中心",
    --         }
    --     },
    --     prerequisites = {
    --         "建造科研中心",
    --     },
	-- },

    -- {
    --     name = "",
	-- 	narrative = {
    --         {"现在需要一个{/g 无人机仓库I}来存储{/color:4bd0ff 组装机}生产的{/g 地质科技包}..哔哩..(期待)", "textures/guide/guide-1.texture"},
    --         {"在组装机附近的{/color:4bd0ff 无人机仓库I}选择物品{/g 地质科技包}后，无人机就可以开始搬运了..哔哩..(期待)", "textures/guide/guide-1.texture"},
    --     },
    --     narrative_end = {
    --         pop_chapter = {"第一章","自动生产"},
    --         guide_progress = 48,--10
    --         task = {
    --             "第三个无人机仓库I",
    --         }
    --     },
    --     prerequisites = {
    --         "科技包产线搭建",
    --     },
	-- },


    -- {
    --     name = "guide-8",
	-- 	narrative = {
    --         {"哔哩..哔哩..矿物采集进展非常顺利，{/g 存活概率}大幅提升至0.3244%！(高兴)", "textures/guide/guide-3.texture"},
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


    -- {
    --     name = "",
	-- 	narrative = {
    --         {"随着基地建设扩大，{/color:4bd0ff 电能}负担越来越大，我们需要补充{/g 发电设施}..哔哩..哔哗..(期待)", "textures/guide/guide-2.texture"},
    --         {"4031星球白天日照充足,利用{/color:4bd0ff 太阳能}发电将是最佳选择..哔哩..(高兴)", "textures/guide/guide-3.texture"},
    --     },
    --     narrative_end = {
    --         guide_progress = 49,
    --         task = {
    --             "道路研究",
    --         }
    --     },
    --     prerequisites = {
    --         "生产石砖",
    --     },
	-- },

    {
        name = "",
		narrative = {
            {"基地{/color:4bd0ff 东面}有未开发的{/g 铁矿}，前往开采铁矿需要更便捷物流方式..哔哩..哔哗..(期待)", "textures/guide/guide-2.texture"},
            {"修建{/g 公路}可以让我们使用{/color:4bd0ff 运输车辆}抵达{/g 铁矿}..哔哗(高兴)", "textures/guide/guide-3.texture"},
        },
        narrative_end = {
            guide_progress = 49,
            task = {
                "公路研究",
            }
        },
        prerequisites = {
            "铁矿石开采",
        },
	},


    {
        name = "",
		narrative = {
            {"修建{/g 公路}需要专用建筑——{/g 建造中心},让我们立即放置一座{/g 建造中心}..哔哗..(期待)", "textures/guide/guide-1.texture"},
        },
        narrative_end = {
            guide_progress = 52,
            task = {
                "建造公路",
            }
        },
        prerequisites = {
            "公路研究",
        },
	},

    -- {
    --     name = "",
	-- 	narrative = {
    --         {"使用{/g 电线杆}将我们刚铺设的{/g 太阳能板}连接入{/color:4bd0ff 电网},这样基地就会获得更多电能..哔哩..哔哗..(期待)", "textures/guide/guide-2.texture"},
    --     },
    --     narrative_end = {
    --         guide_progress = 50,
    --         task = {
    --             "电力覆盖",
    --         }
    --     },
    --     prerequisites = {
    --         "放置太阳能板",
    --     },
	-- }, 

    
    -- {
    --     name = "",
	-- 	narrative = {
    --         {"{/color:4bd0ff 石砖}是铺设{/color:4bd0ff 公路}的最佳材料..哔哩..哔哗..(期待)", "textures/guide/guide-2.texture"},
    --         {"{/color:4bd0ff 建造中心}选择{/g 砖石公路打印}就可以开始建造公路了..哔哩..哔哗..(期待)", "textures/guide/guide-2.texture"},
    --     },
    --     narrative_end = {
    --         guide_progress = 51,
    --         task = {
    --             "通向铁矿",
    --         }
    --     },
    --     prerequisites = {
    --         "建造公路",
    --     },
	-- }, 



    {
        name = "",
		narrative = {
            {"我们需要以{/g 指挥中心}为起点修建一条通往{/g 铁矿}的{/color:4bd0ff 道路}..哔哗..(期待)", "textures/guide/guide-2.texture"},
            {"{/color:4bd0ff 道路}可以通行{/g 运输车辆},这样可以大大提高我们远程物流的效率..哔哗..(高兴)", "textures/guide/guide-2.texture"},
        },
        narrative_end = {
            guide_progress = 53,
            task = {
                "通向铁矿",
            }
        },
        prerequisites = {
            "建造公路",
        },
	},

    {
        name = "",
		narrative = {
            {"是时候开采这个星球的新资源——{/color:4bd0ff 铁矿}了，让我们在铁矿上再放置一台{/g 采矿机}吧..哔哗..(期待)", "textures/guide/guide-2.texture"},
        },
        narrative_end = {
            guide_progress = 55,
            task = {
                "铁矿放置采矿机",
            }
        },
        prerequisites = {
            "物流学1",
        },
	},

    {
        name = "",
		narrative = {
            {"哔哩..哔哗..基地开始采集气液资源，{/g 管道}正是运输此类资源的关键..(高兴)", "textures/guide/guide-3.texture"},
        },
        narrative_end = {
            guide_progress = 56,
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
            guide_progress = 57,
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
            {"我们具备了提取空气中有用气体的能力..哔哩..(高兴)", "textures/guide/guide-2.texture"},
            {"很多稀有气体可以用于工业生产，让我们开始研究{/g 空气分离}吧..哔哩..哔哩(高兴)", "textures/guide/guide-3.texture"},
        },
        narrative_end = {
            guide_progress = 58,
            task = {
            }
        },
        prerequisites = {
        },
	},

    {
        name = "",
		narrative = {
            {"{/g 化工厂}准备就绪，让我们正式进入化工生产..哔哩..哔哩..(高兴）", "textures/guide/guide-3.texture"},
        },
        narrative_end = {
            pop_chapter = {"第二阶段","化工生产"},
            guide_progress = 59,
            task = {
            }
        },
        prerequisites = {
        },
	},

    {
        name = "",
		narrative = {
            {"{/g 塑料}可制造更多精密元件，掌握这种新材料，存活概率提升为{/color:4bd0ff 1.2923%}..哔哩(高兴）", "textures/guide/guide-3.texture"},
        },
        narrative_end = {
            guide_progress = 60,
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
            guide_progress = 61,
            task = {
            }
        },
        prerequisites = {
        },
	},

}

return guide