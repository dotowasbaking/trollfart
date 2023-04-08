--- Does cool things
-- @classmod TeamOnlyPermission
-- @author frick

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Compliance"))

local BaseObject = require("BaseObject")

local TeamOnlyPermission = setmetatable({}, BaseObject)
TeamOnlyPermission.__index = TeamOnlyPermission

function TeamOnlyPermission.new(obj)
    local self = setmetatable(BaseObject.new(obj), TeamOnlyPermission)

    return self
end

function TeamOnlyPermission:CanActivate(player, interactionHint)
    local interactionObject = interactionHint:GetInteractionTarget()
    if not interactionObject then
        return false
    end

    if player.Neutral then
        return false
    end

    return player.Team.Name == interactionObject:GetAttribute("Team")
end

return TeamOnlyPermission