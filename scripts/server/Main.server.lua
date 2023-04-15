--- Main server initialization point

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Compliance"))

local startTime = os.clock()

require("NotificationService"):Init()
require("ServerTemplateProvider"):Init()
require("SoftShutdown"):Init()

require("ServerClassBinders"):Init()
require("InteractableClassBinders"):Init()

local ServerClassBinders = require("ServerClassBinders")

local Players = game:GetService("Players")

local function addc(character)
    local ikLegs = ServerClassBinders.IKLegs:BindAsync(character)

    local thing = character:WaitForChild("HumanoidRootPart").step

    local function play()
        thing.PitchShiftSoundEffect.Octave = 1 + math.random(-20, 20)/200
        thing:Play()
    end

    ikLegs.Footstep:Connect(play)

    ServerClassBinders.IKLegs:Bind(workspace:WaitForChild("StarterCharacter"))
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(addc)
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player.Character then
        addc(player.Character)
    end
end

print(("Server started in %f")
        :format(os.clock() - startTime))