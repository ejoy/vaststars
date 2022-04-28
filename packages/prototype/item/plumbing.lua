local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.prototype

prototype "液罐1" {
    type = {"item"},
    stack = 50,
    icon = "textures/construct/tank1.texture",
    model = "prefabs/rock.prefab",
    description = "专门贮藏液体或气体的容器",
}

prototype "抽水泵" {
    type = {"item"},
    stack = 50,
    icon = "textures/construct/offshore-pump.texture",
    model = "prefabs/rock.prefab",
    description = "从水源抽取水的装置",
}

prototype "压力泵1" {
    type = {"item"},
    stack = 50,
    icon = "textures/construct/pump1.texture",
    model = "prefabs/rock.prefab",
    description = "抽取并传输液体或气体的装置",
}

prototype "烟囱1" {
    type = {"item"},
    stack = 50,
    icon = "textures/construct/chimney2.texture",
    model = "prefabs/rock.prefab",
    description = "用来排放无害气体的装置",
}

prototype "排水口1" {
    type = {"item"},
    stack = 50,
    icon = "textures/construct/outfall.texture",
    model = "prefabs/rock.prefab",
    description = "用来排放无害液体的装置",
}

prototype "空气过滤器1" {
    type = {"item"},
    stack = 25,
    icon = "textures/construct/air-filter1.texture",
    model = "prefabs/rock.prefab",
    description = "抽取空气的装置",
}

prototype "管道1" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/pipe.texture",
    model = "prefabs/rock.prefab",
    description = "在地上传输液体或气体的管道",
}

prototype "地下管1" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/pipe.texture",
    model = "prefabs/rock.prefab",
    description = "从地下传输液体或气体的管道",
}