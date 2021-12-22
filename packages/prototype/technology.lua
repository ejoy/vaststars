local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.prototype


prototype "地质瓶研究" {
    effects = {
      {"unlock-recipe","地质瓶1"},
      {"unlock-recipe","铁锭"},
    },
    prerequisites = {"无"},
    ingredients = {
        {"地质瓶", 1},
        {"空气瓶", 1},
    },
    time = 4,
}



