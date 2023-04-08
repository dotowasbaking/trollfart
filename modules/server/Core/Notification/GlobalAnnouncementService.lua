--- Connects MessagingService to display a message in every server
-- @classmod GlobalAnnouncementService
-- @author frick

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Compliance"))

local MessagingService = game:GetService("MessagingService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local GlobalAnnouncementConstants = require("GlobalAnnouncementConstants")
local NotificationService = require("NotificationService")

local GlobalAnnouncementService = {}

function GlobalAnnouncementService:Init()
    if RunService:IsStudio() then
        return
    end

    task.spawn(function()
        self:_init()
    end)
end

function GlobalAnnouncementService:_init()
    local success, err = pcall(
        MessagingService.SubscribeAsync,
        MessagingService,
        GlobalAnnouncementConstants.TOPIC_NAME,
        function(content) -- We always use JSON here
            NotificationService:SystemMessage(HttpService:JSONDecode(content.Data).Message)
        end
    )
    if not success then
        warn(("[GlobalAnnouncementService] - Failed to SubscribeAsync due to %q, retrying in 15s")
            :format(err))
        task.wait(15)
        self:_init()
    else
        self._initialized = true
    end
end

function GlobalAnnouncementService:IsInitialized()
    return self._initialized and true or false
end

return GlobalAnnouncementService