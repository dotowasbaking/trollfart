--- Does cool things
-- @classmod AnimationTrack
-- @author frick

local AnimationTrack = {}
AnimationTrack.__index = AnimationTrack

function AnimationTrack.new(humanoid, id)
    local animation = Instance.new("Animation")
    animation.AnimationId = ("rbxassetid://%i"):format(id)
    --animation.Parent = humanoid

    return humanoid:LoadAnimation(animation)
end

return AnimationTrack