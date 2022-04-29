local gameplay = import_package "vaststars.gameplay"
import_package "vaststars.prototype"

return {
    query = gameplay.query,
    queryByName = gameplay.queryByName,
    prototype_name = gameplay.prototype_name,
}