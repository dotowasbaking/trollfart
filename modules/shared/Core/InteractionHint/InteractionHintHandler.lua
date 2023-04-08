--- Does cool things
-- @classmod InteractionHintHandler
-- @author frick

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Compliance"))

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local ClientClassBinders = require("ClientClassBinders")
local MouseCaster = require("MouseCaster")
local GuiTemplateProvider = require("GuiTemplateProvider")
local InteractionHintConstants = require("InteractionHintConstants")
local ScreenGuiProvider = require("ScreenGuiProvider")
local TableUtils = require("TableUtils")
local InteractionHintInputs = require("InteractionHintInputs")
local Signal = require("Signal")
local Maid = require("Maid")

local InteractionHintHandler = {}

-- Very messy code below (beware ️️⚠)️️️️️
function InteractionHintHandler:Init()
    self._mouseCaster = MouseCaster.new(function(mouseResult)
        if mouseResult.Instance.Name == "waltuh" then
            return false
        end

        return not mouseResult.Instance.CanCollide
    end)
    self._maid = Maid.new()
    local character = Players.LocalPlayer.Character
    self._inputMap = TableUtils.swapArrange(InteractionHintInputs)
    self._activeInputs = {}

    if character then
        self:_addCharacter(character)
    end
    Players.LocalPlayer.CharacterAdded:Connect(function(character)
        self:_addCharacter(character)
    end)

    self.HintChanged = Signal.new()

    RunService.Heartbeat:Connect(function()
        local mouseResult = self._mouseCaster:Cast()

        if mouseResult then
            local interactionHint = ClientClassBinders.InteractionHint:Get(mouseResult.Instance)
            if interactionHint and self:_validateVisibility(interactionHint) then
                local guid = interactionHint:GetGUID()
                if guid == self._lastGUID then
                    return
                end

                self._lastGUID = guid
                self.HintChanged:Fire(interactionHint)
            elseif self._lastGUID then
                self._lastGUID = nil
                self.HintChanged:Fire()
            end
        elseif self._lastGUID then
            self._lastGUID = nil
            self.HintChanged:Fire()
        end
    end)

    self._maid:AddTask(UserInputService.InputBegan:Connect(function(inputObject, gameProcessedEvent)
        if gameProcessedEvent then
            return
        end

        local input = inputObject.KeyCode.Name ~= "Unknown" and inputObject.KeyCode or inputObject.UserInputType
        local inputIndex = self._inputMap[input]
        if inputIndex then
            self._activeInputs[input] = true
            if self._currentHint and self._currentHint:GetInputIndex() == inputIndex then
                self._currentHint:HandleActivation(0)
            end
        end
    end))
    self._maid:AddTask(UserInputService.InputEnded:Connect(function(inputObject)
        local input = inputObject.KeyCode.Name ~= "Unknown" and inputObject.KeyCode or inputObject.UserInputType
        local inputIndex = self._inputMap[input]

        if inputIndex then
            self._activeInputs[input] = nil
            if self._currentHint and self._currentHint:GetInputIndex() == inputIndex then
                self._currentHint:HandleActivation(1)
            end
        end
    end))

    self.HintChanged:Connect(function(hint)
        self._currentHint = hint

        if hint then
            local hintMaid = Maid.new()
            self._maid.HintMaid = hintMaid

            local screenGui = hintMaid:AddTask(ScreenGuiProvider:Get(InteractionHintConstants.SCREEN_GUI_NAME))
            local hintGui = hintMaid:AddTask(GuiTemplateProvider:Get(InteractionHintConstants.UI_ELEMENT_NAME))

            hintGui.Visible = false
            hintGui.Parent = screenGui

            local hintInput = hint:GetInput()
            local colorFormat = hintInput and
                ([[<font color="rgb(%i, %i, %i)">%s:</font>  ]])
                    :format(
                        math.round(InteractionHintConstants.INPUT_HINT_COLOR.R * 255),
                        math.round(InteractionHintConstants.INPUT_HINT_COLOR.G * 255),
                        math.round(InteractionHintConstants.INPUT_HINT_COLOR.B * 255),
                        hintInput.Name
                    ) or
                    ""
            hintGui.Text = ("%s%s"):format(colorFormat, hint:GetHint())
            hintGui.Visible = true

            hintMaid:AddTask(function()
                hintGui.Visible = false

                if hint.HandleActivation then -- May no longer exist
                    hint:HandleActivation(1)
                end
            end)
            hintMaid:AddTask(hint:GetHintChangedSignal():Connect(function()
                hintGui.Text = ("%s%s"):format(colorFormat, hint:GetHint())
            end))
            hintMaid:AddTask(RunService.RenderStepped:Connect(function()
                local mouseXY = UserInputService:GetMouseLocation()
                hintGui.Position = UDim2.fromOffset(mouseXY.X, mouseXY.Y - 36)
            end))

            if hintInput then
                if self._activeInputs[hintInput] then
                    hint:HandleActivation(0)
                end
            end
        else
            self._maid.HintMaid = nil
        end
    end)
end

function InteractionHintHandler:_addCharacter(character)
    self._character = character
    for _, part in ipairs(character:GetDescendants()) do
        if not part:IsA("BasePart") or part.Name == "waltuh" then
            continue
        end

        self._mouseCaster:Ignore(part)
    end

    character:WaitForChild("Humanoid").Died:Connect(function()
        self._character = nil
    end)
end

function InteractionHintHandler:_validateVisibility(hint)
    if not self._character then
        return false
    end

    local humanoidRootPart = self._character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        warn("[InteractionHintHandler] - No HumanoidRootPart")
        return false
    end

    return
        (hint:GetObject().Position - humanoidRootPart.Position).Magnitude < InteractionHintConstants.MAX_VISIBILITY_RANGE and
        hint:CanActivate()
end

return InteractionHintHandler