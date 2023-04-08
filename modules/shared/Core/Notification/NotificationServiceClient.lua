--- Various notification methods for the client
-- @classmod NotificationServiceClient
-- @author frick

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Compliance"))

local StarterGui = game:GetService("StarterGui")

local Network = require("Network")
local NotificationServiceConstants = require("NotificationServiceConstants")

local NotificationServiceClient = {}

function NotificationServiceClient:Init()
    Network:GetRemoteEvent(NotificationServiceConstants.REMOTE_EVENT_NAME).OnClientEvent:Connect(function(action, ...)
        self[action](self, ...)
    end)
end

function NotificationServiceClient:SystemMessage(message, color)
	StarterGui:SetCore("ChatMakeSystemMessage", {
		Text = message;
		Color = color or NotificationServiceConstants.DEFAULT_SYSTEM_MESSAGE_COLOR;
	})
end

return NotificationServiceClient