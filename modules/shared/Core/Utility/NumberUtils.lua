--- Does cool things
-- @classmod NumberUtils
-- @author frick

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Compliance"))

local NumberUtils = {}

function NumberUtils.validate(num)
    return type(num) == "number" and num == num
end

return NumberUtils