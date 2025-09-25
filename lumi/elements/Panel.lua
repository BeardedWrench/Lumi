-- Panel element for Lumi UI
-- Provides a container with optional titlebar and close button

local Panel = {}
local Class = require('lumi.core.util.class')
local Base = require('lumi.elements.Base')
local Draw = require('lumi.core.draw')
local Theme = require('lumi.core.theme')
local Geom = require('lumi.core.util.geom')

-- Panel class
local PanelElement = Base.BaseElement:extend()

function PanelElement:init()
  PanelElement.__super.init(self)
  
  -- Panel-specific properties
  self.title = nil
  self.titlebarHeight = Theme.spacing.titlebarHeight
  self.closable = false
  self.draggable = false
  self.closeButtonSize = 16
  
  -- Dragging state
  self._dragging = false
  self._dragOffsetX = 0
  self._dragOffsetY = 0
  
  -- Close button state
  self._closeButtonHovered = false
  self._closeButtonPressed = false
  
  -- Set default background
  self:setBackgroundColor(Theme.colors.panel)
  self:setBorderColor(Theme.colors.border)
end

-- Title and titlebar setters
function PanelElement:setTitle(title)
  self.title = title
  return self
end

function PanelElement:setClosable(closable)
  self.closable = closable
  return self
end

function PanelElement:setDraggable(draggable)
  self.draggable = draggable
  return self
end

function PanelElement:setTitlebarHeight(height)
  self.titlebarHeight = height or Theme.spacing.titlebarHeight
  return self
end

-- Override preferred size to account for titlebar
function PanelElement:preferredSize()
  local w, h = PanelElement.__super.preferredSize(self)
  
  if self.title then
    h = h + self.titlebarHeight
  end
  
  return w, h
end

-- Override layout to handle titlebar
function PanelElement:layout(rect)
  local layoutRect = PanelElement.__super.layout(self, rect)
  
  if self.title then
    -- Adjust content area to account for titlebar
    local contentRect = Geom.inset(layoutRect, self.titlebarHeight, 0, 0, 0)
    self._contentRect = contentRect
  else
    self._contentRect = layoutRect
  end
  
  return layoutRect
end

-- Get content rectangle (for children)
function PanelElement:getContentRect()
  return self._contentRect or self:getLayoutRect()
end

-- Override hit test to handle titlebar and close button
function PanelElement:hitTest(x, y)
  if not self.visible or not self.enabled then
    return nil
  end
  
  local rect = self:getLayoutRect()
  if not rect then
    return nil
  end
  
  if Geom.pointInRect(x, y, rect) then
    -- Check close button first
    if self.closable and self.title then
      local closeRect = self:getCloseButtonRect()
      if Geom.pointInRect(x, y, closeRect) then
        return self
      end
    end
        
    -- Check children in content area
    local contentRect = self:getContentRect()
    if contentRect and Geom.pointInRect(x, y, contentRect) then
      for i = #self.children, 1, -1 do
        local child = self.children[i]
        local hit = child:hitTest(x, y)
        if hit then
          return hit
        end
      end
    end
    
    return self
  end
  
  return nil
end

-- Get close button rectangle
function PanelElement:getCloseButtonRect()
  local rect = self:getLayoutRect()
  if not rect or not self.title then
    return Geom.rect(0, 0, 0, 0)
  end
  
  local buttonSize = self.closeButtonSize
  local padding = 4
  
  return Geom.rect(
    rect.x + rect.w - buttonSize - padding,
    rect.y + (self.titlebarHeight - buttonSize) / 2,
    buttonSize,
    buttonSize
  )
end

-- Override mouse events for dragging and close button
function PanelElement:onMousePress(button, x, y)
  if button == 1 then -- Left mouse button
    if self.closable and self.title then
      local closeRect = self:getCloseButtonRect()
      if Geom.pointInRect(x, y, closeRect) then
        self._closeButtonPressed = true
        return
      end
    end
    
    if self.draggable and self.title then
      local titlebarRect = self:getTitlebarRect()
      if Geom.pointInRect(x, y, titlebarRect) then
        self._dragging = true
        local rect = self:getLayoutRect()
        self._dragOffsetX = x - rect.x
        self._dragOffsetY = y - rect.y
        return
      end
    end
  end
  
  PanelElement.__super.onMousePress(self, button, x, y)
end

function PanelElement:onMouseRelease(button, x, y)
  if button == 1 then -- Left mouse button
    if self._closeButtonPressed then
      local closeRect = self:getCloseButtonRect()
      if Geom.pointInRect(x, y, closeRect) then
        -- Close button clicked
        if self.onClose then
          self:onClose()
        end
      end
      self._closeButtonPressed = false
      return
    end
    
    if self._dragging then
      self._dragging = false
      return
    end
  end
  
  PanelElement.__super.onMouseRelease(self, button, x, y)
end

function PanelElement:onMouseMove(x, y)
  if self._dragging then
    -- Update position
    local newX = x - self._dragOffsetX
    local newY = y - self._dragOffsetY
    self:setPos(newX, newY)
    return
  end
  
  -- Update close button hover state
  if self.closable and self.title then
    local closeRect = self:getCloseButtonRect()
    local wasHovered = self._closeButtonHovered
    self._closeButtonHovered = Geom.pointInRect(x, y, closeRect)
    
    if self._closeButtonHovered ~= wasHovered then
      -- Close button hover state changed
    end
  end
  
  PanelElement.__super.onMouseMove(self, x, y)
end

-- Get titlebar rectangle
function PanelElement:getTitlebarRect()
  local rect = self:getLayoutRect()
  if not rect or not self.title then
    return Geom.rect(0, 0, 0, 0)
  end
  
  return Geom.rect(rect.x, rect.y, rect.w, self.titlebarHeight)
end

-- Override draw to render panel, titlebar, and close button
function PanelElement:draw(pass)
  if not self.visible then
    return
  end
  
  local rect = self:getLayoutRect()
  if not rect then
    return
  end
  
  -- Draw panel background
  if self.backgroundColor then
    local bg = self.backgroundColor
    local alpha = bg[4] * self.alpha
    Draw.roundedRect(pass, rect.x, rect.y, rect.w, rect.h, 
      self.borderRadius, bg[1], bg[2], bg[3], alpha)
  end
  
  -- Draw panel border
  if self.borderColor and self.borderWidth > 0 then
    local border = self.borderColor
    local alpha = border[4] * self.alpha
    Draw.rectBorder(pass, rect.x, rect.y, rect.w, rect.h, 
      self.borderWidth, border[1], border[2], border[3], alpha)
  end
  
  -- Draw titlebar
  if self.title then
    local titlebarRect = self:getTitlebarRect()
    local titlebarColor = Theme.colors.background
    local titlebarAlpha = titlebarColor[4] * self.alpha
    
    Draw.rect(pass, titlebarRect.x, titlebarRect.y, titlebarRect.w, titlebarRect.h,
      titlebarColor[1], titlebarColor[2], titlebarColor[3], titlebarAlpha)
    
    -- Draw title text
    local textX = titlebarRect.x + 8
    local textY = titlebarRect.y + (titlebarRect.h - Theme.typography.fontSize) / 2
    Draw.text(pass, self.title, textX, textY, Theme.typography.fontSize,
      Theme.colors.text[1], Theme.colors.text[2], Theme.colors.text[3], 
      Theme.colors.text[4] * self.alpha)
    
    -- Draw close button
    if self.closable then
      local closeRect = self:getCloseButtonRect()
      local closeColor = Theme.colors.text
      local closeAlpha = closeColor[4] * self.alpha
      
      if self._closeButtonHovered then
        closeColor = Theme.colors.hover
        closeAlpha = closeColor[4] * self.alpha
      end
      
      if self._closeButtonPressed then
        closeColor = Theme.colors.press
        closeAlpha = closeColor[4] * self.alpha
      end
      
      -- Draw close button background
      Draw.rect(pass, closeRect.x, closeRect.y, closeRect.w, closeRect.h,
        closeColor[1], closeColor[2], closeColor[3], closeAlpha)
      
      -- Draw X symbol
      local centerX = closeRect.x + closeRect.w / 2
      local centerY = closeRect.y + closeRect.h / 2
      local size = 8
      
      -- Draw X lines
      local xColor = {1, 1, 1, 1}
      local xAlpha = xColor[4] * self.alpha
      pass:setColor(xColor[1], xColor[2], xColor[3], xAlpha)
      
      local points = {
        centerX - size/2, centerY - size/2, 0,
        centerX + size/2, centerY + size/2, 0,
        centerX + size/2, centerY - size/2, 0,
        centerX - size/2, centerY + size/2, 0
      }
      
      pass:line(points, 2)
    end
  end
  
  -- Draw children in content area
  local contentRect = self:getContentRect()
  if contentRect then
    for _, child in ipairs(self.children) do
      child:draw(pass)
    end
  end
end

-- Close callback
function PanelElement:onClose(callback)
  self.onClose = callback
  return self
end

-- Export the class
Panel.PanelElement = PanelElement
Panel.Create = function() return PanelElement:Create() end

return Panel
