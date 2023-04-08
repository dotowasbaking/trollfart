--- Does cool things
-- @classmod TableUtils
-- @author frick

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Compliance"))

local TableUtils = {}

function TableUtils.swapArrange(t)
    local newTable = {}
    for i, v in pairs(t) do
        newTable[v] = i
    end

    return newTable
end

function TableUtils.indexMap(t)
    local newTable = {}
    for i, _ in pairs(t) do
        newTable[#newTable + 1] = i
    end

    return newTable
end

return TableUtils