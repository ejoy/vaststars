package.path = "engine/?.lua"
require "bootstrap"
import_package "vaststars.prototype"

do
    local iprototype = import_package "vaststars.gamerender"("gameplay.interface.prototype")
    local function check_elements(recipe_name, name, s)
        local r = {}
        for idx = 2, #s // 4 do
            local id = string.unpack("<I2I2", s, 4 * idx - 3)
            local typeobject = assert(iprototype.queryById(id), ("can not found id `%s`"):format(id))
            assert(not r[typeobject.name], ("recipe `%s` has duplicate %s `%s`"):format(recipe_name, name, typeobject.name))
            r[typeobject.name] = true
        end
        return r
    end

    for _, v in pairs(iprototype.each_maintype "recipe") do
        check_elements(v.name, "ingredient", v.ingredients)
        check_elements(v.name, "result", v.results)
    end
end

print "ok"
