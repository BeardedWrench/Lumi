package.path = package.path .. ";./?.lua;./?/init.lua"

local UI = require('lumi')

local Panel = UI.Panel
local Label = UI.Label
local Button = UI.Button
local Stack = UI.Stack

function createMinimalUI()
  
  local panel = Panel:Create()
    :setTitle("Test Panel")
    :setSize(300, 200)
    :setAnchors('center', 'center')
    :setClosable(true)
  
  -- Set the close callback after creating the panel
  panel:onClose(function()
    -- Hide the panel instead of quitting the app
    panel:setVisible(false)
  end)
  
  local stack = Stack:Create()
    :setDirection('column')
    :setGap(8)
    :setAnchors('left', 'top')
    :setFullWidth(true)
    :setFullHeight(true)
    :setPadding(15, 15, 15, 15)
  
  local label1 = Label:Create()
    :setText("First Label")
    :setTextColor(1, 1, 1, 1)

  local label2 = Label:Create()
    :setText("Second Label")
    :setTextColor(1, 1, 1, 1)  
  
  stack:addChild(label1)
  stack:addChild(label2)
  
  panel:addChild(stack)

  return panel
end

function lovr.load()
  local panel = createMinimalUI()
  UI.setRoot(panel)
end

function lovr.update(dt)
  UI.update(dt)
end

function lovr.draw(pass)
  local w, h = lovr.system.getWindowDimensions()
  UI.draw(pass, w, h)
end

function lovr.keypressed(key)
  if key == 'escape' then
    lovr.event.quit()
  elseif key == 'd' or key == 'D' then
    local Debug = require('lumi.core.debug')
    Debug.toggle()
    if Debug.getState().enabled then
      Debug.showAll()
    else
      print("Debug mode disabled")
    end
  elseif key == 'i' or key == 'I' then
    local Debug = require('lumi.core.debug')
    local UI = require('lumi')
    local context = UI.getContext()
    local root = context:getRoot()
    if root then
      print("=== ELEMENT INFORMATION ===")
      Debug.logElementInfo(root)
      print("=== END ELEMENT INFORMATION ===")
    end
  end
end

function lovr.mousepressed(x, y, button)
  UI.mousepressed(x, y, button)
end

function lovr.mousereleased(x, y, button)
  UI.mousereleased(x, y, button)
end

function lovr.mousemoved(x, y, dx, dy)
  -- Forward mouse movement to UI system
  local Input = require('lumi.core.input')
  Input.updateMousePosition(x, y)
end

function lovr.textinput(text)
  UI.textinput(text)
end
