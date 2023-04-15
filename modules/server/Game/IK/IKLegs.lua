--- Does cool things
-- @classmod IKLegs
-- @author frick

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Compliance"))

local BaseObject = require("BaseObject")

local IKLegs = setmetatable({}, BaseObject)
IKLegs.__index = IKLegs

function IKLegs.new(obj)
    local self = setmetatable(BaseObject.new(obj), IKLegs)

    return self
end

return IKLegs