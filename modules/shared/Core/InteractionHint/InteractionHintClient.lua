--- Does cool things
-- @classmod InteractionHintClient
-- @author frick

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Compliance"))

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local BaseObject = require("BaseObject")
local InteractionHintConstants = require("InteractionHintConstants")
local InteractableClassBindersClient = require("InteractableClassBindersClient")
local InteractionHintInputs = require("InteractionHintInputs")
local InteractionHintPermissions = require("InteractionHintPermissions")

local InteractionHintClient = setmetatable({}, BaseObject)
InteractionHintClient.__index = InteractionHintClient

function InteractionHintClient.new(obj)
    local self = setmetatable(BaseObject.new(obj), InteractionHintClient)

    self._permissionName = self._obj:GetAttribute(InteractionHintConstants.PERMISSION_ATTRIBUTE_NAME)
    if self._permissionName then
        self._permission = InteractionHintPermissions[self._permissionName].new()
    end

    self._interactionTargetValue = self._obj:WaitForChild(InteractionHintConstants.INTERACTION_TARGET_NAME)
    self._remoteEvent = self._obj:WaitForChild(InteractionHintConstants.REMOTE_EVENT_NAME)
    self._guid = HttpService:GenerateGUID(false)

    return self
end

function InteractionHintClient:BindPermission(permission)
    table.insert(self._permissions, permission)
end

function InteractionHintClient:GetGUID()
    return self._guid
end

function InteractionHintClient:GetHint()
    return self._obj:GetAttribute(InteractionHintConstants.HINT_ATTRIBUTE_NAME)
end

function InteractionHintClient:SetHint(hint)
    self._obj:SetAttribute(InteractionHintConstants.HINT_ATTRIBUTE_NAME, hint)
end

function InteractionHintClient:GetHintChangedSignal()
    return self._obj:GetAttributeChangedSignal(InteractionHintConstants.HINT_ATTRIBUTE_NAME)
end

function InteractionHintClient:GetInputIndex()
    return self._obj:GetAttribute(InteractionHintConstants.INPUT_INDEX_ATTRIBUTE_NAME)
end

function InteractionHintClient:GetInput()
    return InteractionHintInputs[self:GetInputIndex()]
end

function InteractionHintClient:GetInteractionTarget()
    return self._interactionTargetValue.Value
end

function InteractionHintClient:CanActivate()
    if not self._permission then
        return true
    end
    if not self._permission:CanActivate(Players.LocalPlayer, self) then
        return false
    end

    return true
end

function InteractionHintClient:HandleActivation(state)
    if state == 0 and (not self:CanActivate()) then
        return
    end
    self._remoteEvent:FireServer(state)

    for _, classBinder in ipairs(InteractableClassBindersClient:GetAll()) do
        local boundClass = classBinder:Get(self._interactionTargetValue.Value)
        if boundClass and boundClass[InteractionHintConstants.CLASS_ACTIVATION_METHOD_NAME] then
            boundClass[InteractionHintConstants.CLASS_ACTIVATION_METHOD_NAME](boundClass, state, self)
        end
    end
end

return InteractionHintClient