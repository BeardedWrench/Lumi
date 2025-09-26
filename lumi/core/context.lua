-- UI Context for Lumi
-- Manages the root element, theme, fonts, and input routing

local Context = {}
local Class = require('lumi.core.util.class')
local Input = require('lumi.core.input')
local Draw = require('lumi.core.draw')
local Theme = require('lumi.core.theme')
local Geom = require('lumi.core.util.geom')
local Debug = require('lumi.core.debug')
local LayoutSystem = require('lumi.core.layout_system')

-- UI Context class
local UIContext = Class:extend()

function UIContext:init()
  self.root = nil
  self.theme = Theme
  self.font = nil
  self.tooltips = {}
  self.zLayers = {}
  self.scale = 1.0
  self.debug = Debug
  self.baseWidth = 800  -- Smaller base resolution for better scaling
  self.baseHeight = 600
  
  -- Initialize z-layers
  for name, z in pairs(Theme.zLayers) do
    self.zLayers[z] = {}
  end
  
  -- Initialize input
  Input.init()
  
  -- Set up input element finder
  Input.findElementAt = function(x, y)
    return self:findElementAt(x, y)
  end
end

-- Set UI scale
function UIContext:setScale(scale)
  self.scale = scale or 1.0
end

-- Get UI scale
function UIContext:getScale()
  return self.scale
end

-- Set base resolution for scaling
function UIContext:setBaseResolution(width, height)
  self.baseWidth = width or 800
  self.baseHeight = height or 600
end

-- Calculate scale based on window size
function UIContext:calculateScale(windowWidth, windowHeight)
  local scaleX = windowWidth / self.baseWidth
  local scaleY = windowHeight / self.baseHeight
  return math.min(scaleX, scaleY) -- Use the smaller scale to maintain aspect ratio
end

-- Set the root element
function UIContext:setRoot(root)
  self.root = root
end

-- Get the root element
function UIContext:getRoot()
  return self.root
end

-- Set font
function UIContext:setFont(font)
  self.font = font
end

-- Get font
function UIContext:getFont()
  return self.font
end

-- Update UI (called from UI.update)
function UIContext:update(dt)
  -- Update input
  Input.update(dt)
  
  -- Update tooltips
  self:updateTooltips(dt)
  
  -- Update root element
  if self.root then
    self.root:update(dt)
  end
end

-- Draw UI (called from UI.draw)
function UIContext:draw(pass, width, height)
  -- Calculate scale based on window size
  local scale = self:calculateScale(width, height)
  self.scale = scale
  
  -- Set up orthographic projection with proper scaling and correct Y-axis
  local scaledWidth = width / scale
  local scaledHeight = height / scale
  -- Fix Y-axis: use (0, 0, width, height, -1, 1) for normal Y-axis (0 at top)
  local ortho = lovr.math.mat4():orthographic(0, scaledWidth, 0, scaledHeight, -1, 1)
  
  pass:setProjection(1, ortho)
  pass:setViewPose(1, 0, 0, 0, 0, 0, 0, 1)
  
  -- Set font
  if self.font then
    pass:setFont(self.font)
  end
  
  -- Layout root element if it exists using the new layout system
  if self.root then
    local screenRect = {x = 0, y = 0, w = scaledWidth, h = scaledHeight}
    LayoutSystem.layoutTree(self.root, screenRect)
    
    -- Draw root element and its children
    self.root:draw(pass)
  end
  
  -- Draw tooltips last
  self:drawTooltips(pass)
  
  -- Draw debug info if enabled
  if self.debug then
    self.debug:debugUI(pass, self.root)
  end
end

-- Add element to z-layer
function UIContext:addToZLayer(element, zLayer)
  local z = Theme.zLayers[zLayer] or zLayer or Theme.zLayers.content
  if not self.zLayers[z] then
    self.zLayers[z] = {}
  end
  table.insert(self.zLayers[z], element)
end

-- Remove element from z-layer
function UIContext:removeFromZLayer(element, zLayer)
  local z = Theme.zLayers[zLayer] or zLayer or Theme.zLayers.content
  if self.zLayers[z] then
    for i, e in ipairs(self.zLayers[z]) do
      if e == element then
        table.remove(self.zLayers[z], i)
        break
      end
    end
  end
end

-- Update tooltips
function UIContext:updateTooltips(dt)
  local hover = Input.getHover()
  local mouseX, mouseY = Input.getMousePosition()
  
  -- Scale mouse coordinates
  mouseX = mouseX / self.scale
  mouseY = mouseY / self.scale
  
  -- Update existing tooltips
  for i = #self.tooltips, 1, -1 do
    local tooltip = self.tooltips[i]
    tooltip.timer = tooltip.timer - dt
    
    if tooltip.timer <= 0 then
      tooltip.visible = true
    end
    
    -- Remove tooltip if mouse moved away
    if tooltip.element ~= hover then
      table.remove(self.tooltips, i)
    end
  end
  
  -- Add new tooltip if hovering over element with tooltip
  if hover and hover.tooltip and hover.tooltip.text then
    local hasTooltip = false
    for _, tooltip in ipairs(self.tooltips) do
      if tooltip.element == hover then
        hasTooltip = true
        break
      end
    end
    
    if not hasTooltip then
      table.insert(self.tooltips, {
        element = hover,
        text = hover.tooltip.text,
        timer = Theme.animation.tooltipDelay,
        visible = false,
        x = mouseX + 10,
        y = mouseY - 10
      })
    end
  end
end

-- Draw tooltips
function UIContext:drawTooltips(pass)
  for _, tooltip in ipairs(self.tooltips) do
    if tooltip.visible then
      local text = tooltip.text
      local maxWidth = Theme.spacing.tooltipMaxWidth
      local fontSize = Theme.typography.fontSizeSmall
      
      -- Estimate tooltip size
      local textWidth = 0
      local lines = {text}
      
      -- Simple word wrapping
      if text:len() > 50 then
        lines = {}
        local words = {}
        for word in text:gmatch("%S+") do
          table.insert(words, word)
        end
        
        local currentLine = ""
        for _, word in ipairs(words) do
          local testLine = currentLine
          if currentLine ~= "" then
            testLine = testLine .. " " .. word
          else
            testLine = word
          end
          
          if testLine:len() * fontSize * 0.6 <= maxWidth then
            currentLine = testLine
          else
            if currentLine ~= "" then
              table.insert(lines, currentLine)
              currentLine = word
            else
              table.insert(lines, word)
              currentLine = ""
            end
          end
        end
        
        if currentLine ~= "" then
          table.insert(lines, currentLine)
        end
      end
      
      local tooltipWidth = 0
      for _, line in ipairs(lines) do
        tooltipWidth = math.max(tooltipWidth, line:len() * fontSize * 0.6)
      end
      tooltipWidth = math.min(tooltipWidth + Theme.spacing.tooltipPadding * 2, maxWidth)
      
      local tooltipHeight = #lines * fontSize * Theme.typography.lineHeight + Theme.spacing.tooltipPadding * 2
      
      -- Position tooltip to stay on screen
      local x = tooltip.x
      local y = tooltip.y
      
      -- Get scaled screen dimensions
      local screenWidth = self.baseWidth
      local screenHeight = self.baseHeight
      
      if x + tooltipWidth > screenWidth then
        x = screenWidth - tooltipWidth - 10
      end
      if y - tooltipHeight < 0 then
        y = tooltipHeight + 10
      end
      
      -- Draw tooltip
      Draw.tooltip(pass, x, y, tooltipWidth, tooltipHeight, text)
    end
  end
end

-- Find element at coordinates
function UIContext:findElementAt(x, y)
  if not self.root then
    return nil
  end
  
  -- Scale coordinates
  x = x / self.scale
  y = y / self.scale
  
  return self.root:hitTest(x, y)
end

-- Set input element finder
function UIContext:setInputElementFinder(finder)
  Input.findElementAt = finder
end

-- Global context instance
local context = nil

-- Get or create global context
function Context.getContext()
  if not context then
    context = UIContext:Create()
  end
  return context
end

-- Initialize context
function Context.init()
  context = UIContext:Create()
  return context
end

return Context