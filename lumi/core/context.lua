local Context = {}
local Class = require('lumi.core.util.class')
local Input = require('lumi.core.input')
local Draw = require('lumi.core.draw')
local Theme = require('lumi.core.theme')
local Geom = require('lumi.core.util.geom')
local Debug = require('lumi.core.debug')
local LayoutSystem = require('lumi.core.layout_system')

local UIContext = Class:extend()

function UIContext:init()
  self.root = nil
  self.theme = Theme
  self.font = nil
  self.tooltips = {}
  self.zLayers = {}
  self.scale = 1.0
  self.debug = Debug
  self.lastWindowWidth = nil
  self.lastWindowHeight = nil
  self.enableScaling = false  
  self.uiScale = 1.0  
  
  for name, z in pairs(Theme.zLayers) do
    self.zLayers[z] = {}
  end
  
  Input.init()
end

function UIContext:setScale(scale)
  self.scale = scale or 1.0
end

function UIContext:getScale()
  return self.scale
end

function UIContext:calculateScale(windowWidth, windowHeight)
  if self.enableScaling then
    
    return self.uiScale
  else
    
    return 1.0
  end
end

function UIContext:updateLayout()
  if not self.root then
    return
  end
  
  local windowWidth, windowHeight = lovr.system.getWindowDimensions()
  
  if self.lastWindowWidth ~= windowWidth or self.lastWindowHeight ~= windowHeight then
    self.lastWindowWidth = windowWidth
    self.lastWindowHeight = windowHeight
    
    self.scale = self:calculateScale(windowWidth, windowHeight)
    self.scaledWidth = windowWidth
    self.scaledHeight = windowHeight
    
    local screenRect = {x = 0, y = 0, w = self.scaledWidth, h = self.scaledHeight}
    
    LayoutSystem.layoutTree(self.root, screenRect)
  end
end

function UIContext:setRoot(root)
  self.root = root
  if self.root then
    self:updateLayout()
  end
end

function UIContext:getRoot()
  return self.root
end

function UIContext:setUIScale(scale)
  self.uiScale = scale or 1.0
  
  if self.root then
    self:updateLayout()
  end
end

function UIContext:setEnableScaling(enable)
  self.enableScaling = enable
  
  if self.root then
    self:updateLayout()
  end
end

function UIContext:setFont(font)
  self.font = font
end

function UIContext:getFont()
  return self.font
end

function UIContext:mousepressed(x, y, button)
  Input.onMousePress(button, x, y)
end

function UIContext:mousereleased(x, y, button)
  Input.onMouseRelease(button, x, y)
end

function UIContext:textinput(text)
  Input.onTextInput(text)
end

function UIContext:update(dt)
  Input.update(dt)
  self:updateLayout()
  self:updateTooltips(dt)
  if self.root then
    self.root:update(dt)
  end
end

function UIContext:draw(pass, width, height)
  local scaledWidth = width
  local scaledHeight = height
  local ortho = lovr.math.mat4():orthographic(0, scaledWidth, 0, scaledHeight, -1, 1)
  
  pass:setProjection(1, ortho)
  pass:setViewPose(1, 0, 0, 0, 0, 0, 0, 1)
  
  if self.font then
    pass:setFont(self.font)
  end
  
  if self.root then
    self.root:draw(pass)
  end
  
  self:drawTooltips(pass)
  
  if self.debug then
    self.debug:debugUI(pass, self.root)
  end
  
      -- Draw debug overlays for hitboxes
      local Input = require('lumi.core.input')
      Input.drawDebugOverlays(pass)
end

function UIContext:addToZLayer(element, zLayer)
  local z = Theme.zLayers[zLayer] or zLayer or Theme.zLayers.content
  if not self.zLayers[z] then
    self.zLayers[z] = {}
  end
  table.insert(self.zLayers[z], element)
end

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

function UIContext:updateTooltips(dt)
  local hover = Input.getHover()
  local mouseX, mouseY = Input.getMousePosition()
  
  mouseX = mouseX / self.scale
  mouseY = mouseY / self.scale
  
  for i = #self.tooltips, 1, -1 do
    local tooltip = self.tooltips[i]
    tooltip.timer = tooltip.timer - dt
    if tooltip.timer <= 0 then
      tooltip.visible = true
    end
    
    if tooltip.element ~= hover then
      table.remove(self.tooltips, i)
    end
  end
  
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

function UIContext:drawTooltips(pass)
  for _, tooltip in ipairs(self.tooltips) do
    if tooltip.visible then
      local text = tooltip.text
      local maxWidth = Theme.spacing.tooltipMaxWidth
      local fontSize = Theme.typography.fontSizeSmall
      
      local textWidth = 0
      local lines = {text}
      
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
      
      local x = tooltip.x
      local y = tooltip.y
      
      local screenWidth = self.baseWidth
      local screenHeight = self.baseHeight
      
      if x + tooltipWidth > screenWidth then
        x = screenWidth - tooltipWidth - 10
      end
      if y - tooltipHeight < 0 then
        y = tooltipHeight + 10
      end
      
      Draw.tooltip(pass, x, y, tooltipWidth, tooltipHeight, text)
    end
  end
end

function UIContext:findElementAt(x, y)
  if not self.root then
    return nil
  end
  
  x = x / self.scale
  y = y / self.scale
  
  return self.root:hitTest(x, y)
end

function UIContext:setInputElementFinder(finder)
  Input.findElementAt = finder
end

local context = nil

function Context.getContext()
  if not context then
    context = UIContext:Create()
  end
  return context
end

function Context.init()
  context = UIContext:Create()
  return context
end

return Context
