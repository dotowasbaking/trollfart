--- Binds a class to an instance
-- @classmod ClientClassBinders
-- @author frick

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Compliance"))

local CollectionService = game:GetService("CollectionService")

local Signal = require("Signal")

local ClassBinder = {}
ClassBinder.__index = ClassBinder

function ClassBinder.new(name, class)
    local self = setmetatable({}, ClassBinder)
    self._name = name
    self._class = class
    self._boundInstances = {}
    self._processingInstances = {} -- Cope with yielding constructors

    self.InstanceAdded = Signal.new()
    self.InstanceRemoving = Signal.new()

    for _, instance in ipairs(CollectionService:GetTagged(self._name)) do
        task.spawn(self._bind, self, instance)
    end
    CollectionService:GetInstanceAddedSignal(self._name):Connect(function(instance)
        self:_bind(instance)
    end)
    CollectionService:GetInstanceRemovedSignal(self._name):Connect(function(instance)
        local boundClass = self._boundInstances[instance]
        if not boundClass then
            return
        end

        self.InstanceRemoving:Fire(instance)
        if boundClass.Destroy then
            boundClass:Destroy()
        end
        self._boundInstances[instance] = nil
    end)

    return self
end

function ClassBinder:_bind(instance)
    local oldClass = self._boundInstances[instance]
    if oldClass then
        return oldClass
    end

    if self._processingInstances[instance] then
        return
    end

    self._processingInstances[instance] = true
    local newClass = self._class.new(instance)
    self._boundInstances[instance] = newClass
    self.InstanceAdded:Fire(instance)
    self._processingInstances[instance] = nil

    return newClass
end

function ClassBinder:Bind(instance)
    CollectionService:AddTag(instance, self._name)

    return self:Get(instance)
end

function ClassBinder:BindAsync(instance)
    return self:Bind(instance) or self:GetAsync(instance)
end

function ClassBinder:Unbind(instance)
    CollectionService:RemoveTag(instance, self._name)
end

function ClassBinder:Get(instance)
    return self._boundInstances[instance]
end

function ClassBinder:GetAsync(instance)
    local currentThread = coroutine.running()

    local class = self:Get(instance)
    if class then
        return class
    end

    local once; once = self.InstanceAdded:Connect(function(inst)
        if inst == instance then
            coroutine.resume(currentThread, self:Get(inst))
            once:Disconnect()
        end
    end)

    return coroutine.yield()
end

function ClassBinder:GetAll()
    local classRefs = {}
    for _, class in pairs(self._boundInstances) do
        table.insert(classRefs, class)
    end

    return classRefs
end

function ClassBinder:GetName()
    return self._name
end

return ClassBinder