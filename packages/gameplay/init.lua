require "type.init"

local csystem = require "register.csystem"

csystem "powergrid"
csystem "burner"
csystem "assembling"
csystem "inserter"

local pipeline = require "register.pipeline"
pipeline "update"
    .stage "update"
pipeline "rebuild"
    .stage "init"
    .stage "rebuild"
