--- Does cool things
-- @classmod InteractionHint
-- @author frick

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Compliance"))

local BaseObject = require("BaseObject")
local InteractionHintConstants = require("InteractionHintConstants")
local InteractableClassBinders = require("InteractableClassBinders")
local InteractionHintPermissions = require("InteractionHintPermissions")

local InteractionHint = setmetatable({}, BaseObject)
InteractionHint.__index = InteractionHint

function InteractionHint.new(obj)
    local self = setmetatable(BaseObject.new(obj), InteractionHint)

    self._interactionTargetValue = self._obj:WaitForChild(InteractionHintConstants.INTERACTION_TARGET_NAME)
    self._permissionName = self._obj:GetAttribute(InteractionHintConstants.PERMISSION_ATTRIBUTE_NAME)
    if self._permissionName then
        self._permission = InteractionHintPermissions[self._permissionName].new()
    end

    self._remoteEvent = self._maid:AddTask(Instance.new("RemoteEvent"))
    self._remoteEvent.Name = InteractionHintConstants.REMOTE_EVENT_NAME
    self._remoteEvent.Parent = self._obj
    self._maid:AddTask(self._remoteEvent.OnServerEvent:Connect(function(...)
        self:HandleActivation(...)
    end))

    return self
end

function InteractionHint:GetHint()
    return self._obj:GetAttribute(InteractionHintConstants.HINT_ATTRIBUTE_NAME)
end

function InteractionHint:GetObject()
    return self._obj
end

function InteractionHint:BindPermission(permissionClass)
    table.insert(self._permissions, permissionClass)
end

function InteractionHint:GetInteractionTarget()
    return self._interactionTargetValue.Value
end

function InteractionHint:HandleActivation(player, state)
    if state == 0 and (self._permission and not self._permission:CanActivate(player, self)) then
        return
    end

    for _, classBinder in ipairs(InteractableClassBinders:GetAll()) do
        local boundClass = classBinder:Get(self._interactionTargetValue.Value)
        if boundClass and boundClass[InteractionHintConstants.CLASS_ACTIVATION_METHOD_NAME] then
            boundClass[InteractionHintConstants.CLASS_ACTIVATION_METHOD_NAME](boundClass, state, self, player)
        end
    end
end

return InteractionHint