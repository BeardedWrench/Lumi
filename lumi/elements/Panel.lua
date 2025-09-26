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
local LayoutSystem = require('lumi.core.layout_system')

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
  self._contentBoxCreated = false
  
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
      :setBackgroundColor(1, 0, 0, 0.2)  -- Transparent background
      :setBorderWidth(0)  -- No border
      :setAnchors('left', 'top')
      :setPos(0, self.titlebarHeight)  -- Position below titlebar
      :setFullWidth(true)  -- Full width
      :setHeight(100)  -- Temporary height, will be updated in setSize
      :setZIndex(Theme.zLayers.content)
    -- Add content box as child (use parent's addChild to avoid circular reference)
    PanelElement.__super.addChild(self, self.contentBox)
  end
end

-- Set panel title
function PanelElement:setTitle(title)
  self.title = title
  
  -- Create titlebar if it doesn't exist (regardless of title)
  if not self.titlebar then
    self.titlebar = Box:Create()
      :setBackgroundColor(0.2, 0.2, 0.2, 1.0)
      :setBorderWidth(0)
      :setHeight(self.titlebarHeight)
      :setFullWidth(true)
      :setAnchors('left', 'top')
      :setPos(0, 0)
      :setZIndex(Theme.zLayers.content + 1)
    self:addChild(self.titlebar)
    
    -- Create content box only if not already created
    if not self._contentBoxCreated then
      self:_createContentBox()
      self._contentBoxCreated = true
    end
  end
  
  -- Create title label if we have a title and titlebar
  if title and self.titlebar and not self.titleLabel then
    self.titleLabel = Label:Create()
      :setTextColor(Theme.colors.text[1], Theme.colors.text[2], Theme.colors.text[3], Theme.colors.text[4])
      :setAnchors('center', 'center')
      :setPos(0, 0)
      :setHeight(self.titlebarHeight)
      :setZIndex(Theme.zLayers.content + 2)
    self.titlebar:addChild(self.titleLabel)
  end
  
  -- Update title text if label exists
  if self.titleLabel then
    self.titleLabel:setText(title or "")
  end
  
  return self
end

-- Override setSize to update content box height
function PanelElement:setSize(w, h)
  local result = PanelElement.__super.setSize(self, w, h)
  
  -- Update content box height if it exists
  if self.contentBox then
    local contentBoxHeight = self.h - self.titlebarHeight
    self.contentBox:setHeight(contentBoxHeight)
  end
  
  return result
end

-- Set if panel is closable
function PanelElement:setClosable(closable)
  self.closable = closable
  
  -- Create close button if closable and we have a titlebar
  if closable and self.titlebar and not self.closeButton then
    self.closeButton = Button:Create()
      :setText("×")
      :setPadding(2)  -- Minimal padding for close button
      :setAnchors('right', 'center')
      :setPos(8, 0)
      :setIdleColor(0.3, 0.3, 0.3, 1.0)
      :setHoverColor(0.4, 0.4, 0.4, 1.0)
      :setPressColor(0.2, 0.2, 0.2, 1.0)
      :setBorderWidth(1)
      :setBorderColor(0.5, 0.5, 0.5, 1.0)
      :setBorderRadius(2)
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
  if not closable and self.closeButton then
    if self.titlebar then
      self.titlebar:removeChild(self.closeButton)
    end
    self.closeButton = nil
  end
  
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

-- Update method - just update children, no element creation
function PanelElement:update(dt)
  -- Call parent update to update children
  PanelElement.__super.update(self, dt)
end

-- Override layout to handle titlebar and content box positioning
function PanelElement:layout(rect)
  -- Don't override the calculated position - use the rect as-is
  self._layoutRect = rect
  local layoutRect = self._layoutRect
  
  -- Manually layout titlebar relative to panel's full layout rect
  if self.titlebar then
    local titlebarRect = {
      x = layoutRect.x,
      y = layoutRect.y,
      w = layoutRect.w,
      h = self.titlebarHeight
    }
    -- Set titlebar layout rect directly to avoid recursion
    self.titlebar._layoutRect = titlebarRect
  end
  
        -- Update content box position and size
        if self.contentBox then
          -- Get the panel's content area (accounting for padding)
          local contentArea = LayoutSystem.getContentArea(self)
          if contentArea then
            -- Position contentBox below titlebar within the content area
            self.contentBox:setPos(0, self.titlebarHeight)
            -- Set size to fill remaining space below titlebar within content area
            local contentBoxHeight = contentArea.h - self.titlebarHeight
            self.contentBox:setSize(contentArea.w, contentBoxHeight)
            -- Set the content box's layout rect manually to avoid layout system issues
            self.contentBox._layoutRect = {
              x = contentArea.x,
              y = contentArea.y + self.titlebarHeight,
              w = contentArea.w,
              h = contentBoxHeight
            }
          end
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

-- Override addChild to add content to contentBox instead of directly to panel
function PanelElement:addChild(child)
  if child then
    -- If we have a contentBox, add the child to it
    if self.contentBox then
      self.contentBox:addChild(child)
    else
      -- Fallback to direct addition if no contentBox
      PanelElement.__super.addChild(self, child)
    end
  end
  return self
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