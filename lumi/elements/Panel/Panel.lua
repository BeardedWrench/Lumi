local Panel = {}
local Box = require('lumi.elements.foundation.Box')
local Label = require('lumi.elements.Label.Label')
local Button = require('lumi.elements.Button.Button')
local Theme = require('lumi.core.theme')
local LayoutEngine = require('lumi.core.layout_engine')

local PanelElement = Box.BoxElement:extend()

function PanelElement:init()
  PanelElement.__super.init(self)
  self.className = "PanelElement"
  self.title = nil
  self.titlebarHeight = Theme.spacing.titlebarHeight
  self.closable = false
  self.closeButtonSize = 16
  self.titlebar = nil
  self.titleLabel = nil
  self.closeButton = nil
  self.contentBox = nil
  self._contentBoxCreated = false
  self.w = 400
  self.h = 300
  self:setBackgroundColor(Theme.colors.panel[1], Theme.colors.panel[2], Theme.colors.panel[3], Theme.colors.panel[4])
  self:setBorderColor(Theme.colors.border[1], Theme.colors.border[2], Theme.colors.border[3], Theme.colors.border[4])
  self:setBorderWidth(Theme.spacing.borderWidth)
  self:setBorderRadius(Theme.spacing.borderRadius)
  self:setZIndex(Theme.zLayers.panel)
end

function PanelElement:_createContentBox()
  if not self.contentBox then
    self.contentBox = Box:Create()
      :setBackgroundColor(1, 0, 0, 0)  
      :setBorderWidth(0)  
      :setAnchors('left', 'top')
      :setPos(0, self.titlebarHeight)  
      :setFullWidth(true)  
      :setHeight(100)  
      :setZIndex(Theme.zLayers.content)
    PanelElement.__super.addChild(self, self.contentBox)
  end
end

function PanelElement:setTitle(title)
  self.title = title
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
    
    if not self._contentBoxCreated then
      self:_createContentBox()
      self._contentBoxCreated = true
    end
  end
  
  if title and self.titlebar and not self.titleLabel then
    self.titleLabel = Label:Create()
      :setTextColor(Theme.colors.text[1], Theme.colors.text[2], Theme.colors.text[3], Theme.colors.text[4])
      :setAnchors('center', 'center')
      :setPos(0, 0)
      :setHeight(self.titlebarHeight)
      :setZIndex(Theme.zLayers.content + 2)
    self.titlebar:addChild(self.titleLabel)
  end
  
  if self.titleLabel then
    self.titleLabel:setText(title or "")
  end
  
  -- Set the titlebar as the drag area when title is set
  if self.titlebar then
    self:setDragArea(self.titlebar)
  end
  
  return self
end

function PanelElement:setSize(w, h)
  local result = PanelElement.__super.setSize(self, w, h)
  if self.contentBox then
    local contentBoxHeight = self.h - self.titlebarHeight
    self.contentBox:setHeight(contentBoxHeight)
  end
  return result
end

function PanelElement:setVisible(visible)
  PanelElement.__super.setVisible(self, visible)
  return self
end

function PanelElement:setClosable(closable)
  self.closable = closable
  if closable and self.titlebar and not self.closeButton then
    self.closeButton = Button:Create()
      :setPadding(0)
      :setText("×")
      :setAnchors('right', 'center')
      :setPos(8, 0)
      :setIdleColor(0,0,0,0)
      :setHoverColor(0,0,0,0)
      :setPressColor(0,0,0,0)
      :setBorderColor(0,0,0,0)
      :setIdleTextColor(1, 1, 1, 1.0)
      :setHoverTextColor(0.5, 0.5, 0.5, 1.0)
      :setPressTextColor(0.5, 0.5, 0.5, 1.0)
      :setZIndex(Theme.zLayers.content + 2)
      :onClick(function()
        local panel = self
        if panel.onClose then
          panel.onClose()
        end
      end)
    self.titlebar:addChild(self.closeButton)
  end
  
  if not closable and self.closeButton then
    if self.titlebar then
      self.titlebar:removeChild(self.closeButton)
    end
    self.closeButton = nil
  end
  
  return self
end

-- Draggable setter is inherited from BaseElement

function PanelElement:onClose(callback)
  self.onClose = callback
  return self
end

function PanelElement:update(dt)
  
  PanelElement.__super.update(self, dt)
end

function PanelElement:layout(rect)
  self._layoutRect = rect
  local layoutRect = self._layoutRect
  
  if self.titlebar then
    local titlebarRect = {
      x = layoutRect.x,
      y = layoutRect.y,
      w = layoutRect.w,
      h = self.titlebarHeight
    }
    
    self.titlebar._layoutRect = titlebarRect
  end
        if self.contentBox then
          
          local contentArea = LayoutEngine.getContentArea(self)
          if contentArea then
            self.contentBox:setPos(0, self.titlebarHeight)
            local contentBoxHeight = contentArea.h - self.titlebarHeight
            self.contentBox:setSize(contentArea.w, contentBoxHeight)
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

function PanelElement:getContentRect()
  local layoutRect = self:getLayoutRect()
  if not layoutRect then
    return nil
  end
  
  if self.title and self.titlebar then
    return {
      x = layoutRect.x,  
      y = layoutRect.y + self.titlebarHeight,  
      w = layoutRect.w,
      h = layoutRect.h - self.titlebarHeight
    }
  else
    return PanelElement.__super.getContentRect(self)
  end
end

function PanelElement:addChild(child)
  if child then
    if self.contentBox then
      self.contentBox:addChild(child)
    else
      PanelElement.__super.addChild(self, child)
    end
  end
  return self
end

function PanelElement:draw(pass)
  PanelElement.__super.draw(self, pass)
end

function PanelElement:hitTest(x, y)
  if not self.visible or not self.enabled then
    return nil
  end
  local rect = self:getLayoutRect()
  if not rect then return nil end
  if x >= rect.x and x <= rect.x + rect.w and y >= rect.y and y <= rect.y + rect.h then
    if self.title and self.titlebar and self.draggable then
      local titlebarRect = self.titlebar:getLayoutRect()
      if titlebarRect and x >= titlebarRect.x and x <= titlebarRect.x + titlebarRect.w and 
         y >= titlebarRect.y and y <= titlebarRect.y + titlebarRect.h then
        return self
      end
    end
    for _, child in ipairs(self.children) do
      local hit = child:hitTest(x, y)
      if hit then return hit end
    end
    return self
  end
  return nil
end

-- All mouse event handling is now done by the drag system

function PanelElement:Create()
  local instance = setmetatable({}, PanelElement)
  instance:init()
  return instance
end

Panel.PanelElement = PanelElement
Panel.Create = PanelElement.Create

return Panel
