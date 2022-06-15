local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "液罐I" {
    type = {"item"},
    stack = 50,
    icon = "textures/construct/tank1.texture",
    model = "prefabs/rock.prefab",
    description = "专门贮藏液体或气体的容器",
    group = "管道",
    order = 22,
}

prototype "地下水挖掘机" {
    type = {"item"},
    stack = 50,
    icon = "textures/construct/offshore-pump.texture",
    model = "prefabs/rock.prefab",
    description = "从水源抽取水的装置",
    group = "管道",
    order = 50,
}

prototype "压力泵I" {
    type = {"item"},
    stack = 50,
    icon = "textures/construct/pump1.texture",
    model = "prefabs/rock.prefab",
    description = "抽取并传输液体或气体的装置",
    group = "管道",
    order = 40,
}

prototype "烟囱I" {
    type = {"item"},
    stack = 50,
    icon = "textures/construct/chimney2.texture",
    model = "prefabs/rock.prefab",
    description = "用来排放无害气体的装置",
    group = "管道",
    order = 65,
}

prototype "排水口I" {
    type = {"item"},
    stack = 50,
    icon = "textures/construct/outfall.texture",
    model = "prefabs/rock.prefab",
    description = "用来排放无害液体的装置",
    group = "管道",
    order = 56,
}

prototype "空气过滤器I" {
    type = {"item"},
    stack = 25,
    icon = "textures/construct/air-filter1.texture",
    model = "prefabs/rock.prefab",
    description = "抽取空气的装置",
    group = "管道",
    order = 60,
}

prototype "管道1-I型" {
    show_prototype_name = "管道I",
    type = {"item"},
    stack = 100,
    icon = "textures/construct/pipe.texture",
    model = "prefabs/rock.prefab",
    description = "在地上传输液体或气体的管道",
    group = "管道",
    order = 10,
}

prototype "地下管I" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/pipe.texture",
    model = "prefabs/rock.prefab",
    description = "从地下传输液体或气体的管道",
    group = "管道",
    order = 12,
}

prototype "地下管II" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/pipe.texture",
    model = "prefabs/rock.prefab",
    description = "从地下传输液体或气体的管道",
    group = "管道",
    order = 14,
}