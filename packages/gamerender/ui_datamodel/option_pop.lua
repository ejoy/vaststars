local function create(archival_files)
    return {
        archival_files = archival_files,
    }
end

local function update(datamodel, param, archival_files)
    assert(false)
end

return {
    create = create,
    update = update,
}