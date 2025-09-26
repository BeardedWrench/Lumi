-- Panel element for Lumi UI
-- Provides a container with optional titlebar and close button
-- Uses Box elements for proper container hierarchy

local Panel = {}
local Class = require('lumi.core.util.class')
local Base = require('lumi.elements.Base')
local Box = require('lumi.elements.foundation.Box')
local Label = require('lumi.elements.Label')
local Button = require('lumi.elements.Button')
local Theme = require('lumi.core.theme')
local Draw = require('lumi.core.draw')

-- Panel class
local PanelElement = Box.BoxElement:extend()

function PanelElement:init()
  PanelElement.__super.init(self)
  
  -- Panel-specific properties
  self.title = nil
  self.titlebarHeight = Theme.spacing.titlebarHeight
  self.closable = false
  self.draggable = false
  self.closeButtonSize = 16
  
  -- Create titlebar and content as sibling Box elements
  self.titlebar = nil
  self.titleLabel = nil
  self.closeButton = nil
  self.contentBox = nil
  
  -- Dragging state
  self._dragging = false
  self._dragOffsetX = 0
  self._dragOffsetY = 0
  
  -- Default size
  self.w = 400
  self.h = 300
  
  -- Set panel background and border
  self:setBackgroundColor(Theme.colors.panel[1], Theme.colors.panel[2], Theme.colors.panel[3], Theme.colors.panel[4])
  self:setBorderColor(Theme.colors.border[1], Theme.colors.border[2], Theme.colors.border[3], Theme.colors.border[4])
  self:setBorderWidth(Theme.spacing.borderWidth)
  self:setBorderRadius(Theme.spacing.borderRadius)
  self:setZIndex(Theme.zLayers.panel)
end

-- Create the content box for panel content
function PanelElement:_createContentBox()
  if not self.contentBox then
    self.contentBox = Box:Create()
      :setBackgroundColor(0, 0, 0, 0)  -- Transparent background
      :setBorderWidth(0)  -- No border
      :setAnchors('left', 'top')
      :setPos(0, self.titlebarHeight)  -- Position below titlebar
      :setFullWidth(true)  -- Full width
      :setHeight(self.h - self.titlebarHeight)  -- Remaining height
      :setZIndex(Theme.zLayers.content)
    
    -- Add content box as child
    self:addChild(self.contentBox)
  end
end

-- Set panel title
function PanelElement:setTitle(title)
  self.title = title
  return self
end

-- Set if panel is closable
function PanelElement:setClosable(closable)
  self.closable = closable
  return self
end

-- Set if panel is draggable
function PanelElement:setDraggable(draggable)
  self.draggable = draggable
  return self
end

-- Set close callback
function PanelElement:onClose(callback)
  self.onClose = callback
  return self
end

-- Update method to create/update elements based on properties
function PanelElement:update()
  -- Only update if properties have changed
  if self._lastTitle ~= self.title or self._lastClosable ~= self.closable then
    self._lastTitle = self.title
    self._lastClosable = self.closable
    
    -- Create titlebar if we have a title
    if self.title and not self.titlebar then
      self.titlebar = Box:Create()
        :setBackgroundColor(0.2, 0.2, 0.2, 1.0)
        :setBorderWidth(0)
        :setHeight(self.titlebarHeight)
        :setFullWidth(true)
        :setAnchors('left', 'top')
        :setPos(0, 0)
        :setZIndex(Theme.zLayers.content + 1)
      self:addChild(self.titlebar)
      
      -- Create content box
      self:_createContentBox()
    end
    
    -- Create title label if we have a title and titlebar
    if self.title and self.titlebar and not self.titleLabel then
      self.titleLabel = Label:Create()
        :setTextColor(Theme.colors.text[1], Theme.colors.text[2], Theme.colors.text[3], Theme.colors.text[4])
        :setAnchors('center', 'center')
        :setPos(0, 0)
        :setHeight(self.titlebarHeight)
        :setZIndex(Theme.zLayers.content + 2)
        :setBackgroundColor(0, 1, 0, 1)  -- BRIGHT GREEN for debugging
      self.titlebar:addChild(self.titleLabel)
    end
    
    -- Create close button if closable and we have a titlebar
    if self.closable and self.titlebar and not self.closeButton then
      self.closeButton = Button:Create()
        :setText("×")
        :setPadding(2)  -- Minimal padding for close button
        :setAnchors('right', 'center')
        :setPos(8, 0)
        :setBackgroundColor(0, 1, 0, 1)  -- BRIGHT GREEN for debugging
        :setBorderWidth(0)
        :setTextColor(0.8, 0.8, 0.8, 1.0)
        :setZIndex(Theme.zLayers.content + 2)
        :onClick(function()
          if self.onClose then
            self.onClose()
          end
        end)
      self.titlebar:addChild(self.closeButton)
    end
    
    -- Remove close button if not closable
    if not self.closable and self.closeButton then
      if self.titlebar then
        self.titlebar:removeChild(self.closeButton)
      end
      self.closeButton = nil
    end
    
    -- Remove titlebar if no title
    if not self.title and self.titlebar then
      self:removeChild(self.titlebar)
      self.titlebar = nil
      self.titleLabel = nil
      self.closeButton = nil
    end
  end
  
  -- Update title text if it changed
  if self.titleLabel and self.titleLabel.text ~= self.title then
    self.titleLabel:setText(self.title)
  end
end

-- Override layout to handle titlebar and content box positioning
function PanelElement:layout(rect)
  local layoutRect = PanelElement.__super.layout(self, rect)
  
  -- Update elements based on current properties
  self:update()
  
  -- Manually layout titlebar relative to panel's full layout rect
  if self.titlebar then
    local titlebarRect = {
      x = layoutRect.x,
      y = layoutRect.y,
      w = layoutRect.w,
      h = self.titlebarHeight
    }
    LayoutSystem.layoutElement(self.titlebar, titlebarRect)
  end
  
  -- Update content box position and size
  if self.contentBox then
    self.contentBox:setPos(0, self.titlebarHeight)  -- Position below titlebar
    self.contentBox:setHeight(layoutRect.h - self.titlebarHeight)  -- Remaining height
  end
  
  return layoutRect
end

-- Override getContentRect to return the adjusted content area
function PanelElement:getContentRect()
  local layoutRect = self:getLayoutRect()
  if not layoutRect then
    return nil
  end
  
  if self.title and self.titlebar then
    -- Return content area as absolute coordinates (below titlebar)
    return {
      x = layoutRect.x,  -- Absolute X position
      y = layoutRect.y + self.titlebarHeight,  -- Absolute Y position below titlebar
      w = layoutRect.w,
      h = layoutRect.h - self.titlebarHeight
    }
  else
    -- No titlebar, use base implementation
    return PanelElement.__super.getContentRect(self)
  end
end

-- Override draw to use atomic elements
function PanelElement:draw(pass)
  -- Draw panel background (from Box parent)
  PanelElement.__super.draw(self, pass)
  
  -- Draw children (titlebar and content box)
  for _, child in ipairs(self.children) do
    child:draw(pass)
  end
end

-- Override hit test to handle titlebar dragging
function PanelElement:hitTest(x, y)
  if not self.visible or not self.enabled then
    return nil
  end
  
  local rect = self:getLayoutRect()
  if not rect then return nil end
  
  -- Check if hit is within panel bounds
  if x >= rect.x and x <= rect.x + rect.w and y >= rect.y and y <= rect.y + rect.h then
    -- Check titlebar for dragging
    if self.title and self.titlebar and self.draggable then
      local titlebarRect = self.titlebar:getLayoutRect()
      if titlebarRect and x >= titlebarRect.x and x <= titlebarRect.x + titlebarRect.w and 
         y >= titlebarRect.y and y <= titlebarRect.y + titlebarRect.h then
        return self
      end
    end
    
    -- Check children
    for _, child in ipairs(self.children) do
      local hit = child:hitTest(x, y)
      if hit then return hit end
    end
    
    return self
  end
  
  return nil
end

-- Handle mouse events for dragging
function PanelElement:onMousePress(x, y, button)
  if self.draggable and self.title and button == 1 then
    local titlebarRect = self.titlebar:getLayoutRect()
    if titlebarRect and x >= titlebarRect.x and x <= titlebarRect.x + titlebarRect.w and 
       y >= titlebarRect.y and y <= titlebarRect.y + titlebarRect.h then
      self._dragging = true
      self._dragOffsetX = x - self.x
      self._dragOffsetY = y - self.y
      return true
    end
  end
  
  return PanelElement.__super.onMousePress(self, x, y, button)
end

function PanelElement:onMouseRelease(x, y, button)
  if self._dragging then
    self._dragging = false
    return true
  end
  
  return PanelElement.__super.onMouseRelease(self, x, y, button)
end

function PanelElement:onMouseMove(x, y)
  if self._dragging then
    self:setPos(x - self._dragOffsetX, y - self._dragOffsetY)
    return true
  end
  
  return PanelElement.__super.onMouseMove(self, x, y)
end

-- Create a new Panel element
function PanelElement:Create()
  local instance = setmetatable({}, PanelElement)
  instance:init()
  return instance
end

-- Export the Panel class
Panel.PanelElement = PanelElement
Panel.Create = PanelElement.Create

return Panel