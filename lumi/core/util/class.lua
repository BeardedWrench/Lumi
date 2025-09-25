-- Lightweight OOP helper for Lumi UI elements
-- Provides :Create() and :extend() functionality

local Class = {}

function Class:extend(child)
  local child_class = child or {}
  child_class.__index = child_class
  child_class.__super = self
  
  setmetatable(child_class, self)
  
  function child_class:Create(...)
    local instance = setmetatable({}, child_class)
    if instance.init then
      instance:init(...)
    end
    return instance
  end
  
  return child_class
end

function Class:Create(...)
  local instance = setmetatable({}, self)
  if instance.init then
    instance:init(...)
  end
  return instance
end

return Class
