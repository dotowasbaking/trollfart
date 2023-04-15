--- Does cool things
-- @classmod IKLegsClient
-- @author frick

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Compliance"))

local BaseObject = require("BaseObject")
local IKLeg = require("IKLeg")
local Signal = require("Signal")

local IKLegsClient = setmetatable({}, BaseObject)
IKLegsClient.__index = IKLegsClient

function IKLegsClient.new(obj)
    local self = setmetatable(BaseObject.new(obj), IKLegsClient)

    self._rightLeg = self._maid:AddTask(IKLeg.new(self._obj, "Right"))
    self._leftLeg = self._maid:AddTask(IKLeg.new(self._obj, "Left"))

    self.Footstep = Signal.new()

    self._maid:AddTask(self._rightLeg.Footstep:Connect(function()
        self.Footstep:Fire()
    end))
    self._maid:AddTask(self._leftLeg.Footstep:Connect(function()
        self.Footstep:Fire()
    end))

    return self
end

return IKLegsClient