--- Does Cool Things
-- @classmod InteractableClassBinders
-- @author frick

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Compliance"))

-- local ServerClassBinders = require("ServerClassBinders")
local ClassBinderProvider = require("ClassBinderProvider")

return ClassBinderProvider.new(function(self)
    -- self:AddClassBinder(ServerClassBinders.Name)
end)