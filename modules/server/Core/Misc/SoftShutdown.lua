--- Teleports players to a new server when the game is shutdown
-- @classmod SoftShutdown
-- @author Merely, edited by frick

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Compliance"))

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

local NotificationService = require("NotificationService")

local PLACE_ID = game.PlaceId

local SoftShutdown = {}

function SoftShutdown:Init()
    if game.PrivateServerId ~= "" and game.PrivateServerOwnerId == 0 then
        local waitTime = 5

        Players.PlayerAdded:Connect(function(player)
            waitTime /= 2
            task.wait(waitTime)
            TeleportService:Teleport(PLACE_ID, player)
        end)

        for _, player in pairs(Players:GetPlayers()) do
            waitTime /= 2
            TeleportService:Teleport(PLACE_ID, player)
            task.wait(waitTime)
        end

        if #Players:GetPlayers() > 0 then
            Players.PlayerAdded:Wait()
        end
        task.wait(1)
        NotificationService:SystemMessage(
            "This is a temporary server, teleporting back in a moment...",
            Color3.new(1, 0.4, 0)
        )
    else
        game:BindToClose(function()
            if #Players:GetPlayers() == 0 then
                return
            end

            if game:GetService("RunService"):IsStudio() then
                return
            end

            NotificationService:SystemMessage(
                "Server restarting, please wait...",
                Color3.new(0.4, 1, 0)
            )

            local reservedServerCode = TeleportService:ReserveServer(PLACE_ID)
            TeleportService:TeleportToPrivateServer(PLACE_ID, reservedServerCode, Players:GetPlayers())

            Players.PlayerAdded:Connect(function(player)
                TeleportService:TeleportToPrivateServer(PLACE_ID, reservedServerCode, {player})
            end)

            while #Players:GetPlayers() > 0 do
                task.wait(0.5) -- Keep server alive
            end
        end)

        return true
    end
end

return SoftShutdown