--- Main client initialization point

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Compliance"))

local startTime = os.clock()

require("NotificationServiceClient"):Init()
require("ClientTemplateProvider"):Init()
require("GuiTemplateProvider"):Init()

require("ClientClassBinders"):Init()
require("InteractableClassBindersClient"):Init()
require("InteractionHintHandler"):Init()

print(("Client started in %f")
        :format(os.clock() - startTime))