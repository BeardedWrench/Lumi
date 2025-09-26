-- Minimal Panel Test for Lumi UI
-- Just a panel with titlebar, title, and close button

-- Add current directory to package path so we can require 'lumi'
package.path = package.path .. ";./?.lua;./?/init.lua"

local UI = require('lumi')

local Panel = UI.Panel
local Label = UI.Label
local Button = UI.Button
local Stack = UI.Stack

-- Create minimal UI
function createMinimalUI()
  -- Single panel in center of screen
  local panel = Panel:Create()
    :setTitle("Test Panel")
    :setSize(300, 200)
    :setAnchors('center', 'center')
    :setPos(0, 0)  -- Center anchor means 0,0 is center
    :setClosable(true)

  -- Create a stack for content
  local stack = Stack:Create()
    :setDirection('column')
    :setGap(8)
    :setAnchors('left', 'top')
    :setPos(0, 0)  -- Small padding from panel edges
    :setFullWidth(true)
    :setFullHeight(true)
    :setBackgroundColor(0.2, 0.4, 0.8, 0.5)  -- Blue debug background

  -- Create two labels
  local label1 = Label:Create()
    :setText("First Label")
    :setTextColor(1, 1, 1, 1)  -- White text
    :setBackgroundColor(0.2, 0.8, 0.2, 0.7)  -- Green debug background

  local label2 = Label:Create()
    :setText("Second Label")
    :setTextColor(1, 1, 1, 1)  -- White text (changed from gray for visibility)
    :setBackgroundColor(0.8, 0.2, 0.2, 0.7)  -- Red debug background

  -- Add labels to stack
  stack:addChild(label1)
  stack:addChild(label2)

  -- Add stack to panel content
  panel:addChild(stack)

  return panel
end

-- LÖVR callbacks
function lovr.load()
  -- Create and set the minimal UI as root
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
    -- Toggle debug mode
    UI.Debug.showAll()
    print("Debug mode enabled - you should see colored outlines around elements")
  end
end
