-- Minimal Panel Test for Lumi UI
-- Just a panel with titlebar, title, and close button

-- Add current directory to package path so we can require 'lumi'
package.path = package.path .. ";./?.lua;./?/init.lua"

local UI = require('lumi')

local Panel = UI.Panel
local Label = UI.Label
local Button = UI.Button

-- Create minimal UI
function createMinimalUI()
  -- Single panel in center of screen
  local panel = Panel:Create()
    :setTitle("Test Panel")
    :setSize(300, 200)
    :setAnchors('center', 'center')
    :setPos(0, 0)  -- Center anchor means 0,0 is center
    :setClosable(true)

  return panel
end

-- LÖVR callbacks
function lovr.load()
  -- Create and set the minimal UI as root
  local panel = createMinimalUI()
  UI.setRoot(panel)
  
  print("Minimal Panel Test loaded.")
  print("You should see a single panel with titlebar, title, and close button.")
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
