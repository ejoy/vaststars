local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.prototype


prototype "地质瓶研究" {
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "地质瓶1"
      },
    },
    prerequisites = {"无"},
    unit =
    {
      count = 5,
      ingredients = 
      {
        {"无"},
      },
      time = 3
    },
}


prototype "铁矿石熔炼" {
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "铁锭"
      },
    },
    prerequisites = {"地质瓶研究"},
    unit =
    {
      count = 4,
      ingredients = 
      {
        {"地质瓶"},
      },
      time = 4
    },
}
