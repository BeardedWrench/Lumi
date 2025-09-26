local UI = {}
local Context = require('lumi.core.context')
local Theme = require('lumi.core.theme')
local Debug = require('lumi.core.debug')
local Base = require('lumi.elements.Base')

local uiContext = nil

function UI.init()
  uiContext = Context.init()
  return uiContext
end

function UI.getContext()
  if not uiContext then
    uiContext = Context.getContext()
  end
  return uiContext
end

function UI.root()
  local context = UI.getContext()
  return context:getRoot()
end

function UI.setRoot(root)
  local context = UI.getContext()
  context:setRoot(root)
end

function UI.update(dt)
  local context = UI.getContext()
  context:update(dt)
end

function UI.draw(pass, width, height)
  local context = UI.getContext()
  context:draw(pass, width, height)
end

function UI.setFont(font)
  local context = UI.getContext()
  context:setFont(font)
end

function UI.getFont()
  local context = UI.getContext()
  return context:getFont()
end

function UI.setScale(scale)
  local context = UI.getContext()
  context:setScale(scale)
end

function UI.getScale()
  local context = UI.getContext()
  return context:getScale()
end

UI.theme = Theme
UI.Base = Base

function UI.setUIScale(scale)
  local context = UI.getContext()
  context:setUIScale(scale)
end

function UI.setEnableScaling(enable)
  local context = UI.getContext()
  context:setEnableScaling(enable)
end

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
