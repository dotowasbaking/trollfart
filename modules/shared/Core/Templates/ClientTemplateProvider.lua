--- Does cool things
-- @classmod ClientTemplateProvider
-- @author frick

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Compliance"))

local TemplateProvider = require("TemplateProvider")

return TemplateProvider.new(game:GetService("ReplicatedStorage"):WaitForChild("ClientTemplates"))