--- Utility functions for welding
-- @classmod WeldUtils
-- @author frick

local WeldUtils = {}

function WeldUtils.weld(partA, partB, offset)
    local weld = Instance.new("Weld")--Instance.new(offset and "Weld" or "WeldConstraint")

    weld.Part0 = partA
    weld.Part1 = partB
    weld.C0 = offset or partA.CFrame:ToObjectSpace(partB.CFrame)
    weld.Parent = partA

    return weld
end

return WeldUtils