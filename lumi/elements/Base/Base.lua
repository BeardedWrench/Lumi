-- BaseElement - Clean, Modular Version
-- Uses composition pattern with specialized modules

local BaseNew = {}
local Class = require('lumi.core.util.class')
local Theme = require('lumi.core.theme')
local LayoutEngine = require('lumi.core.layout_engine')

-- Import specialized modules
local Properties = require('lumi.elements.Base.Properties')
local Hierarchy = require('lumi.elements.Base.Hierarchy')
local Layout = require('lumi.elements.Base.Layout')

local BaseElement = Class:extend()

function BaseElement:init()
  -- Initialize properties
  Properties.initProperties(self)
  
  -- Set theme defaults
  self.zIndex = Theme.zLayers.content
  self.borderWidth = Theme.spacing.borderWidth
  self.borderRadius = Theme.spacing.borderRadius
end

-- Mix in all the specialized modules
for name, func in pairs(Properties) do
  if type(func) == "function" and name ~= "initProperties" then
    BaseElement[name] = func
  end
end

for name, func in pairs(Hierarchy) do
  if type(func) == "function" then
    BaseElement[name] = func
  end
end

for name, func in pairs(Layout) do
  if type(func) == "function" then
    BaseElement[name] = func
  end
end

-- Core methods
function BaseElement:update(dt)
  -- Override in subclasses
end

function BaseElement:draw(pass)
  -- Override in subclasses
end

function BaseElement:hitTest(x, y)
  return self:containsPoint(x, y)
end

function BaseElement:Create()
  local instance = setmetatable({}, BaseElement)
  instance:init()
  return instance
end

return BaseElement
