--- Main server initialization point

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Compliance"))

local startTime = os.clock()

require("NotificationService"):Init()
require("ServerTemplateProvider"):Init()
require("SoftShutdown"):Init()

require("ServerClassBinders"):Init()
require("InteractableClassBinders"):Init()

print(("Server started in %f")
        :format(os.clock() - startTime))