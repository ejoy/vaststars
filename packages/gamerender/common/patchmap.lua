local function set(self, key, value)
    assert(not self.TEMPORARY[key])
    self.TEMPORARY[key] = value
end

local GET_T <const> = {"TEMPORARY", "CONFIRM", "EXISTING"}
local function get(self, key)
    for _, v in ipairs(GET_T) do
        if self[v][key] then
            return self[v][key]
        end
    end
end

local function revert_temporary(self)
    local temporary = self.TEMPORARY
    self.TEMPORARY = {}
    return temporary
end

local function commit_temporary(self)
    local temporary = self.TEMPORARY
    self.TEMPORARY = {}

    for k, v in pairs(temporary) do
        self.CONFIRM[k] = v
    end
end

local function revert_confirm(self)
    local temporary = revert_temporary(self)

    local confirm = self.CONFIRM
    self.TEMPORARY = {}

    local r = {}
    for k, v in pairs(temporary) do
        r[k] = v
    end
    for k, v in pairs(confirm) do
        r[k] = v
    end
    return r
end

local function commit_confirm(self)
    revert_temporary(self)

    local confirm = self.CONFIRM
    self.CONFIRM = {}

    for k, v in pairs(confirm) do
        self.EXISTING[k] = v
    end
    return confirm
end

local function create()
    local M = {}
    M.TEMPORARY = {}
    M.CONFIRM = {}
    M.EXISTING = {}
    M.set = set
    M.get = get
    M.revert_temporary = revert_temporary
    M.commit_temporary = commit_temporary
    M.revert_confirm = revert_confirm
    M.commit_confirm = commit_confirm

    return setmetatable(M, {__index = M})
end
return create