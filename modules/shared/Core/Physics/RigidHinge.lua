--- Emulates a rigid HingeConstraint using RigidConstraint
-- @classmod RigidHinge
-- @author frick

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Compliance"))

local BaseObject = require("BaseObject")

local RigidHinge = setmetatable({}, BaseObject)
RigidHinge.__index = RigidHinge

RigidHinge.AXIS_INDEX = {
    Roll = {
        PointAt = function(self, point)
            error("Not implemented")
        end;
    };
    Pitch = {
        SpringInitial = 0;
        Axis = "Z";
        PointAt = function(self, point)
            local headTarget = (self._att0.WorldCFrame * self._aimOffset):PointToObjectSpace(point)
            local distance = (self._att0.WorldPosition - point).Magnitude

            local pitch = math.clamp(math.deg(math.asin(headTarget.Y/distance)), self._lowerAngleLimit or -15, self._upperAngleLimit or 85)
            self:SetAngle(pitch)
        end;
        SetAngle = function(self, angle)
            angle = math.clamp(angle, self._lowerAngleLimit or -15, self._upperAngleLimit or 85)
            self._att0.Orientation = Vector3.zAxis * angle
            return angle
        end;
    };
    Yaw = {
        SpringInitial = Vector3.zero;
        Axis = "Y";
        PointAt = function(self, point)
            local baseTarget = self._att0.Parent.CFrame:PointToObjectSpace(point) * (Vector3.one - Vector3.yAxis).Unit

            local yaw = math.deg(math.atan2(baseTarget.X, baseTarget.Z))
            self:SetAngle(yaw + 90)
        end;
        SetAngle = function(self, angle)
            self._att0.Orientation = Vector3.yAxis * angle
            return angle
        end;
    };
}

function RigidHinge.new(obj)
    local self = setmetatable(BaseObject.new(obj), RigidHinge)

    self._axis = assert(self._obj:GetAttribute("Axis"), "No Axis")
    self._axisIndex = self.AXIS_INDEX[self._axis]

    self._att0 = self._obj.Attachment0
    self._att1 = self._obj.Attachment1

    self._angle = self._att0.Orientation[self._axisIndex.Axis]

    self._upperAngleLimit = self._obj:GetAttribute("UpperAngleLimit")
    self._lowerAngleLimit = self._obj:GetAttribute("LowerAngleLimit")

    self._pointAt = self._axisIndex.PointAt
    self._setAngle = self._axisIndex.SetAngle

    self._aimOffset = self._obj:GetAttribute("AimOffset") or CFrame.identity

    return self
end

function RigidHinge:GetConstraint()
    return self._obj
end

function RigidHinge:PointAt(point)
    self:_pointAt(point)
end

function RigidHinge:SetAngle(angle)
    self._angle = self:_setAngle(angle)
end

function RigidHinge:AddAngle(angle)
    self:SetAngle(self._angle + angle)
end

return RigidHinge