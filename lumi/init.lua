-- Lumi UI Library for LÖVR
-- Public API entry point
local UI = {}
local Context = require('lumi.core.context')
local Theme = require('lumi.core.theme')
local Debug = require('lumi.core.debug')

-- Load Base first since other elements depend on it
local Base = require('lumi.elements.Base')

-- UI singleton instance
local uiContext = nil

-- Initialize UI (optional, usually not needed)
function UI.init()
  uiContext = Context.init()
  return uiContext
end

-- Get or create UI context
function UI.getContext()
  if not uiContext then
    uiContext = Context.getContext()
  end
  return uiContext
end

-- Get root element
function UI.root()
  local context = UI.getContext()
  return context:getRoot()
end

-- Set root element
function UI.setRoot(root)
  local context = UI.getContext()
  context:setRoot(root)
end

-- Update UI (call from lovr.update)
function UI.update(dt)
  local context = UI.getContext()
  context:update(dt)
end

-- Draw UI (call from lovr.draw)
function UI.draw(pass, width, height)
  local context = UI.getContext()
  context:draw(pass, width, height)
end

-- Set font
function UI.setFont(font)
  local context = UI.getContext()
  context:setFont(font)
end

-- Get font
function UI.getFont()
  local context = UI.getContext()
  return context:getFont()
end

-- Set UI scale
function UI.setScale(scale)
  local context = UI.getContext()
  context:setScale(scale)
end

-- Get UI scale
function UI.getScale()
  local context = UI.getContext()
  return context:getScale()
end

-- Set base resolution for scaling
function UI.setBaseResolution(width, height)
  local context = UI.getContext()
  context:setBaseResolution(width, height)
end

-- Theme access
UI.theme = Theme

-- Export Base directly
UI.Base = Base

-- Lazy loading using metatable for other elements
setmetatable(UI, {
  __index = function(table, key)
    if key == 'Panel' then
      return require('lumi.elements.Panel')
    elseif key == 'Label' then
      return require('lumi.elements.Label')
    elseif key == 'Button' then
      return require('lumi.elements.Button')
    elseif key == 'Input' then
      return require('lumi.elements.Input')
    elseif key == 'Slot' then
      return require('lumi.elements.Slot')
    elseif key == 'Tooltip' then
      return require('lumi.elements.Tooltip')
    elseif key == 'Stack' then
      return require('lumi.layout.Stack')
    elseif key == 'Debug' then
      return Debug
    elseif key == 'Box' then
      return require('lumi.elements.foundation.Box')
    elseif key == 'RoundedRect' then
      return require('lumi.elements.foundation.RoundedRect')
    elseif key == 'Text' then
      return require('lumi.elements.foundation.Text')
    end
  end
})

return UI