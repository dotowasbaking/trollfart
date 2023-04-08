--- Does cool things
-- @classmod Sightseer
-- @author frick

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Compliance"))

local RunService = game:GetService("RunService")

local BaseObject = require("BaseObject")

local MAX_HORIZONTAL_SPEED = 0.6
local HORIZONTAL_TELEPORT_SPEED = 5

local Sightseer = setmetatable({}, BaseObject)
Sightseer.__index = Sightseer

function Sightseer.new(obj)
    local self = setmetatable(BaseObject.new(obj), Sightseer)

    self._humanoid = self._obj.Humanoid
    self._rootPart = assert(self._humanoid.RootPart)

    self._invalidHTime = 0
    self._totalInvalidHTime = 0

    self:Update(RunService.Heartbeat:Wait())
    self._maid.Update = RunService.Heartbeat:Connect(function(dt)
        self:Update(dt)
    end)
    self._maid:AddTask(self._humanoid.Died:Connect(function()
        self:_killCharacter()
    end))

    return self
end

function Sightseer:Pause(time)
    if not time or time == 0 then
        return
    end

    self._maid.Update = nil
    self._maid:AddTask(task.delay(time, function()
        if self._humanoid.Health <= 0 then
            return
        end

        self._maid.Update = RunService.Heartbeat:Connect(function(dt)
            self:Update(dt)
        end)
    end))
end

function Sightseer:Update(dt)
    local maxHSpeed = MAX_HORIZONTAL_SPEED * dt
    local teleportingHSpeed = HORIZONTAL_TELEPORT_SPEED * dt

    local position = self._rootPart.Position
    local hPosition = Vector2.new(position.X, position.Z)
    local vPosition = position.Y

    local lastHPosition = self._lastHPosition or hPosition
    local lastVPosition = self._lastVPosition or vPosition

    local hSpeed = (lastHPosition - hPosition).Magnitude * dt
    local vSpeed = (vPosition - lastVPosition) * dt

    self._hSpeed = hSpeed
    self._vSpeed = vSpeed

    if hSpeed > teleportingHSpeed then
        if self._humanoid.SeatPart then
            return
        end
        warn("detection 2")
        self:_nullifyCharacter()
        return
    elseif hSpeed > maxHSpeed then
        if self._invalidHTime >= 0.5 then
            warn("detection 1")
            self:_nullifyCharacter()
            return
        else
            self._invalidHTime += dt
            self._totalInvalidHTime += dt
        end
    else
        self._invalidHTime = 0
    end

    if self._totalInvalidHTime >= 6 then
        warn("too many times kid...")
        self:_killCharacter()
    end

    self._lastHPosition = hPosition
    self._lastVPosition = vPosition
end

function Sightseer:_killCharacter()
    if self._dead then
        return
    end

    self._humanoid.Health = 0
    self._maid.Update = nil
    self._dead = true

    -- self._maid.DeadUpdate = RunService.Heartbeat:Connect(function()
    --     if self._rootPart:GetNetworkOwner() then
    --         self._rootPart:SetNetworkOwner()
    --     end
    -- end)
end

function Sightseer:_nullifyCharacter()
    if not self._lastVPosition then
        return
    end

    self._rootPart.AssemblyLinearVelocity = Vector3.zero
    self._rootPart.AssemblyAngularVelocity = Vector3.zero
    self._rootPart.CFrame = CFrame.new(self._lastHPosition.X, self._lastVPosition, self._lastHPosition.Y)
end

return Sightseer