--- Various methods to notify players
-- @classmod NotificationService
-- @author frick

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Compliance"))

local Network = require("Network")
local NotificationServiceConstants = require("NotificationServiceConstants")

local NotificationService = {}

function NotificationService:Init()
    self._remoteEvent = Network:GetRemoteEvent(NotificationServiceConstants.REMOTE_EVENT_NAME)
end

function NotificationService:SystemMessage(message, color)
	self._remoteEvent:FireAllClients("SystemMessage", message, color)
end

return NotificationService