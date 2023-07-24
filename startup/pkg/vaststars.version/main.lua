local version = require "vaststars.version.core"

if __ANT_RUNTIME__ then
    print(("Game Core Version:   %s."):format(version.game))
    print(("Engine Core Version: %s."):format(version.engine))
end
