--- Does Cool Things
-- @classmod InteractableClassBindersClient
-- @author frick

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Compliance"))

-- local ClientClassBinders = require("ClientClassBinders")
local ClassBinderProvider = require("ClassBinderProvider")

return ClassBinderProvider.new(function(self)
    -- self:AddClassBinder(ClientClassBinders.Name)
end)