--- Does cool things
-- @classmod GuiTemplateProvider
-- @author frick

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Compliance"))

local TemplateProvider = require("TemplateProvider")
local GuiTemplateConstants = require("GuiTemplateConstants")

return TemplateProvider.new(GuiTemplateConstants.TEMPLATE_STORAGE)