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
    
    UI.Debug.showAll()
    print("Debug mode enabled - you should see colored outlines around elements")
  end
end
