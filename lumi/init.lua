-- Lumi UI Library for LÖVR
-- Public API entry point

local UI = {}
local Context = require('lumi.core.context')
local Theme = require('lumi.core.theme')

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

-- Theme access
UI.theme = Theme

-- Export element classes
UI.Panel = require('lumi.elements.Panel')
UI.Label = require('lumi.elements.Label')
UI.Button = require('lumi.elements.Button')
UI.Input = require('lumi.elements.Input')
UI.Slot = require('lumi.elements.Slot')
UI.Tooltip = require('lumi.elements.Tooltip')

-- Export layout classes
UI.Stack = require('lumi.layout.Stack')

-- Export utility classes
UI.Base = require('lumi.elements.Base')

return UI
