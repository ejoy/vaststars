local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "液罐I" {
    type = {"item"},
    group = {"化工"},
    stack = 10,
    pile = "2x2x4",
    backpack_stack = 16,
    item_description = "专门贮藏液体的容器",
}

prototype "气罐I" {
    type = {"item"},
    group = {"化工"},
    stack = 10,
    pile = "2x2x4",
    backpack_stack = 16,
    item_description = "专门贮藏气体的容器",
}

prototype "地下水挖掘机I" {
    type = {"item"},
    group = {"化工"},
    stack = 10,
    pile = "2x2x4",
    backpack_stack = 16,
    item_description = "从水源抽取水的装置",
}

prototype "压力泵I" {
    type = {"item"},
    group = {"化工"},
    stack = 10,
    pile = "2x2x4",
    backpack_stack = 16,
    item_description = "抽取并传输液体或气体的装置",
}

prototype "烟囱I" {
    type = {"item"},
    group = {"化工"},
    stack = 10,
    pile = "2x2x4",
    backpack_stack = 16,
    item_description = "用来排放气体的装置",
}

prototype "排水口I" {
    type = {"item"},
    group = {"化工"},
    stack = 10,
    pile = "2x2x4",
    backpack_stack = 16,
    item_description = "用来排放液体的装置",
}

prototype "空气过滤器I" {
    type = {"item"},
    group = {"化工"},
    stack = 10,
    pile = "2x2x4",
    backpack_stack = 16,
    item_description = "抽取空气的装置",
}

prototype "管道1-X型" {
    type = {"item"},
    group = {"化工"},
    stack = 50,
    pile = "4x4x4",
    backpack_stack = 64,
    item_description = "放置在地上传输液体或气体的管道",
}

prototype "地下管1-JI型" {
    type = {"item"},
    group = {"化工"},
    stack = 50,
    pile = "4x4x4",
    backpack_stack = 64,
    item_description = "放置在地下传输液体或气体的管道",
}

prototype "地下管2-JI型" {
    type = {"item"},
    group = {"化工"},
    stack = 50,
    pile = "4x4x4",
    backpack_stack = 64,
    item_description = "放置在地下传输液体或气体的管道",
}