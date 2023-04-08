--- Does cool things
-- @classmod SanitizeUtils
-- @author frick

local SanitizeUtils = {}

function SanitizeUtils.sanitizeCFrame(cframe)
    for _, component in ipairs({cframe:GetComponents()}) do
        if component ~= component then
            return false
        end
    end

    return true
end

return SanitizeUtils