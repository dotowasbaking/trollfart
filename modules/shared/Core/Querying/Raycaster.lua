--- Repeats raycasting attempts while ignoring items via a filter function
-- @classmod Raycaster
-- @author frick

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Compliance"))

local DebugVisualizer = require("DebugVisualizer")

local Raycaster = {}

Raycaster.__index = Raycaster

function Raycaster.new(raycastParams, ignoreFunction)
	local self = setmetatable({}, Raycaster)

    self.MaxCasts = 5;
    self._ignoreList = {};
    self._raycastParams = raycastParams or RaycastParams.new()
	self.Filter = ignoreFunction

	return self
end

function Raycaster:Ignore(object)
	if typeof(object) == "Instance" then
		table.insert(self._ignoreList, object)
	elseif type(object) == "table" then
		for _, instance in pairs(object) do
			table.insert(self._ignoreList, instance)
		end
	end
    self:_updateParams()
end

function Raycaster:Cast(origin, direction)
	for _ = 1, self.MaxCasts do
        local castSuccess, hitData = self:_tryCast(origin, direction)

        if castSuccess then
            return hitData
        end
    end

    warn("[Raycaster] - Ran out of casts")
end

function Raycaster:_updateParams()
    self._raycastParams.FilterDescendantsInstances = self._ignoreList
end

function Raycaster:_tryCast(origin, direction)
	local result = workspace:Raycast(origin, direction, self._raycastParams)

    if result then
        if self.Visualize then
            self:_visualize(origin, result.Position)
        end

        if self.Filter and self.Filter(result) then
            self:Ignore(result.Instance)
            return
        end

        return true, result
    end

    if self.Visualize then
        self:_visualize(origin, origin + direction)
    end

    return true
end

function Raycaster:_visualize(origin, pointB)
    local part = DebugVisualizer:LookAtPart(origin, pointB, 0.7, 0.05)

    part.Parent = workspace.Terrain
    task.delay(10, function()
        part:Destroy()
    end)
end

return Raycaster
