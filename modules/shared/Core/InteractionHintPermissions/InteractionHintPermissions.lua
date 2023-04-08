--- Does cool things
-- @classmod PlayerInterface
-- @author frick

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Compliance"))

return {
    TeamOnlyPermission = require("TeamOnlyPermission");
}