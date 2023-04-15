--- Does cool things
-- @classmod IKLeg
-- @author frick

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Compliance"))

local BaseObject = require("BaseObject")
local Raycaster = require("Raycaster")
local Signal = require("Signal")

local RunService = game:GetService("RunService")

local UPPER_LEG = "UpperLeg"
local LOWER_LEG = "LowerLeg"
local FOOT = "Foot"

local FOOT_INITIAL = "FootInitial"
local LEG_POLE = "LegPole"
local LIMIT = "FootLimit"

local ATTACHMENT_NAME = "LegIKAttachment"
local IK_CONTROL_NAME = "LegController"

local SPEED_MODIFIER = 0.7

local function lookAt(position, target, upVector)
    local lookVector = (target - position).Unit
    local rightVector = upVector:Cross(lookVector).Unit
    local upVectorNew = lookVector:Cross(rightVector)

    return CFrame.fromMatrix(position, rightVector, upVectorNew)
end

local IKLeg = setmetatable({}, BaseObject)
IKLeg.__index = IKLeg

function IKLeg.new(obj, prefix)
    local self = setmetatable(BaseObject.new(obj), IKLeg)

    self._prefix = prefix
    self._timeDiff = 0
    self._theta = 0
    self._theta2 = 0

    self.Footstep = Signal.new()

    self:_init()

    self._controllerIndex = (self._obj:GetAttribute("LegControllers") or 0) + 1
    self._obj:SetAttribute("LegControllers", self._controllerIndex)

    self._targetOffset = self._controllerIndex % 2 == 0 and 0 or math.pi/2
    self._strideLength = self._limit.Position.Y - self._footInitial.Position.Y

    self._maid:AddTask(RunService.Heartbeat:Connect(function(dt)
        local moveDir = self._humanoidRootPart.AssemblyLinearVelocity
        local walkingSpeed = moveDir.Magnitude
        if not self:_isWalking() then
            moveDir = self._humanoidRootPart.CFrame.LookVector
            self._theta2 = math.clamp(self._theta2 * dt, -1, 1)
        else
            self._timeDiff += dt * walkingSpeed
            self._theta = ((self._timeDiff * SPEED_MODIFIER) + self._targetOffset) % math.pi * 2
            self._theta2 = self._theta
        end

        local castDirection = (CFrame.new(Vector3.zero, moveDir) * CFrame.new(0, math.sin(self._theta2) * self._strideLength * 0.8, math.cos(self._theta) * self._strideLength)).Position + Vector3.new(0, -self._strideLength, 0)

        local finalCFrame = nil
        local castOrigin = self._limit.WorldPosition
        local raycastResult = self._raycaster:Cast(castOrigin, castDirection)
        if raycastResult then
            if not self._lastCast then
                self._lastCast = true
                self.Footstep:Fire()
            end
            finalCFrame = lookAt(raycastResult.Position, raycastResult.Position + self._humanoidRootPart.CFrame.LookVector, raycastResult.Normal) * CFrame.fromOrientation(math.rad(-90), math.rad(90), math.rad(-90))
        else
            self._lastCast = false
            finalCFrame = CFrame.new(castOrigin + castDirection)
        end

        self._targetAttachment.WorldCFrame = finalCFrame
    end))

    return self
end

function IKLeg:_isWalking()
    return self._humanoidRootPart.AssemblyLinearVelocity.Magnitude >= 0.1 and self._humanoid:GetState() == Enum.HumanoidStateType.Running
end

function IKLeg:_init()
    self._humanoid = self._obj:WaitForChild("Humanoid")
    self._humanoidRootPart = self._obj:WaitForChild("HumanoidRootPart")

    self._upperLeg = self._obj:WaitForChild(("%s%s"):format(self._prefix, UPPER_LEG))
    self._lowerLeg = self._obj:WaitForChild(("%s%s"):format(self._prefix, LOWER_LEG))
    self._foot = self._obj:WaitForChild(("%s%s"):format(self._prefix, FOOT))

    self._footInitial = self._humanoidRootPart:WaitForChild(("%s%s"):format(self._prefix, FOOT_INITIAL))
    self._legPole = self._humanoidRootPart:WaitForChild(("%s%s"):format(self._prefix, LEG_POLE))
    self._limit = self._humanoidRootPart:WaitForChild(("%s%s"):format(self._prefix, LIMIT))

    self._raycaster = Raycaster.new()
    self._raycaster:Ignore({workspace.Terrain, self._obj})
    -- self._raycaster.Visualize = true

    self._targetAttachment = self._maid:AddTask(Instance.new("Attachment"))
    self._targetAttachment.Name = ("%s%s"):format(self._prefix, ATTACHMENT_NAME)

    self._ikControl = self._maid:AddTask(Instance.new("IKControl"))
    self._ikControl.Name = ("%s%s"):format(self._prefix, IK_CONTROL_NAME)
    self._ikControl.SmoothTime = 0.05
    self._ikControl.ChainRoot = self._upperLeg
    self._ikControl.EndEffector = self._foot
    self._ikControl.Pole = self._legPole
    self._ikControl.Target = self._targetAttachment

    self._ikControl.Enabled = true

    self._targetAttachment.Parent = workspace.Terrain
    self._ikControl.Parent = self._humanoid
end

function IKLeg:_update()

end

return IKLeg