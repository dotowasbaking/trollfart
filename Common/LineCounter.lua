local services = {
    "Workspace";
    "ReplicatedStorage";
    "ServerScriptService";
    "ServerStorage";
    "Lighting";
    "StarterPlayer";
}

local scripts = {
    ["LocalScript"] = true;
    ["Script"] = true;
    ["ModuleScript"] = true;
}

local scriptCount = 0
local lines = 0

for _, serviceName in ipairs(services) do
    for _, script in ipairs(game:GetService(serviceName):GetDescendants()) do
        if scripts[script.ClassName] then
            local lineCount = #script.Source:split("\n")
            scriptCount += 1
            lines += lineCount
        end
    end
end

warn(("lines: %i scripts: %i"):format(lines, scriptCount))