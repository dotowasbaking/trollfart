--- Utility functions for models
-- @classmod ModelUtils
-- @author frick

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Compliance"))

local DebugVisualizer = require("DebugVisualizer")
local AssemblyUtils = require("AssemblyUtils")

local ModelUtils = {}

function ModelUtils.getParts(model)
    local parts = {}
    for _, part in ipairs(model:GetDescendants()) do
        if not part:IsA("BasePart") then
            continue
        end

        table.insert(parts, part)
    end

    return parts
end

function ModelUtils.getPrimaryModel(descendant, parent)
    local model = descendant
    while model and model.Parent ~= parent and model.Parent ~= game do
        model = model.Parent
    end

    return model and model.Parent ~= game and model or nil
end

function ModelUtils.convertToModel(object)
    local newModel = Instance.new("Model")

    for _, obj in ipairs(object:GetChildren()) do
        obj.Parent = newModel
    end
    object:Destroy()
    return newModel
end

function ModelUtils.buildTool(tool)
    AssemblyUtils.rigidAssemble(tool)

    for _, part in ipairs(ModelUtils.getParts(tool)) do
        part.CustomPhysicalProperties = PhysicalProperties.new(0,0,0,0,0)
        part.Massless = true
        part.CanCollide = false
        part.CanQuery = false
        part.Anchored = false
    end
end

function ModelUtils.createBasePart(model)
	local modelCFrame = model:GetBoundingBox()
    modelCFrame = CFrame.new(modelCFrame.Position)

	local basePart = DebugVisualizer:DebugPart()

	basePart.Size = Vector3.zero
	basePart.Name = "BasePart"

	basePart.CFrame = modelCFrame
    basePart.Parent = model

	model.PrimaryPart = basePart

	return basePart
end

return ModelUtils