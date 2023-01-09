local GameplayVersion = require "vaststars.version.core"
local ScriptVersion = require "version"

if GameplayVersion ~= ScriptVersion then
    error(("gameplay (%s) and script (%s) mismatch."):format(GameplayVersion, ScriptVersion))
end
