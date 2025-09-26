-- Text measurement utilities for Lumi UI
-- Provides text sizing and layout calculations

local Measure = {}
local Text = require('lumi.core.util.text')
local Theme = require('lumi.core.theme')

-- Measure text dimensions
function Measure.text(text, fontSize, maxWidth, wrapMode)
  fontSize = fontSize or Theme.typography.fontSize
  maxWidth = maxWidth or math.huge
  wrapMode = wrapMode or 'none'
  
  if wrapMode == 'none' then
    local width = Text.estimateWidth(text)
    local height = fontSize * Theme.typography.lineHeight
    return width, height
  else
    local lines = Text.wrap(text, maxWidth, wrapMode)
    local maxLineWidth = 0
    for _, line in ipairs(lines) do
      local lineWidth = Text.estimateWidth(line)
      maxLineWidth = math.max(maxLineWidth, lineWidth)
    end
    local height = #lines * fontSize * Theme.typography.lineHeight
    return maxLineWidth, height
  end
end

-- Measure element's preferred size
function Measure.elementPreferredSize(element)
  local minWidth = element.minWidth or 0
  local minHeight = element.minHeight or 0
  local preferredWidth = element.preferredWidth or minWidth
  local preferredHeight = element.preferredHeight or minHeight
  
  -- For text elements, measure actual text
  if element.text then
    local fontSize = element.fontSize or Theme.typography.fontSize
    local maxWidth = element.maxWidth or math.huge
    local wrapMode = element.wrapMode or 'none'
    
    local textWidth, textHeight = Measure.text(element.text, fontSize, maxWidth, wrapMode)
    preferredWidth = math.max(preferredWidth, textWidth)
    preferredHeight = math.max(preferredHeight, textHeight)
  end
  
  -- Add padding
  local padding = element.padding or {0, 0, 0, 0}
  preferredWidth = preferredWidth + padding[1] + padding[3] -- left + right
  preferredHeight = preferredHeight + padding[2] + padding[4] -- top + bottom
  
  -- Add border
  local borderWidth = element.borderWidth or Theme.spacing.borderWidth
  preferredWidth = preferredWidth + borderWidth * 2
  preferredHeight = preferredHeight + borderWidth * 2
  
  return preferredWidth, preferredHeight
end

-- Calculate layout rectangle for element
function Measure.calculateLayout(element, parentRect)
  local padding = element.padding or {0, 0, 0, 0}
  local margin = element.margin or {0, 0, 0, 0}
  
  -- Start with parent's content area (minus padding)
  local contentRect = {
    x = parentRect.x + padding[1],
    y = parentRect.y + padding[2],
    w = parentRect.w - padding[1] - padding[3],
    h = parentRect.h - padding[2] - padding[4]
  }
  
  -- Apply margins
  local availableRect = {
    x = contentRect.x + margin[1],
    y = contentRect.y + margin[2],
    w = contentRect.w - margin[1] - margin[3],
    h = contentRect.h - margin[2] - margin[4]
  }
  
  -- Calculate element size
  local elementWidth, elementHeight = Measure.elementPreferredSize(element)
  
  -- Apply sizing constraints
  if element.fullWidth then
    elementWidth = availableRect.w
  end
  if element.fullHeight then
    elementHeight = availableRect.h
  end
  
  -- Apply flex sizing if in flex container
  if element.flexGrow and element.flexGrow > 0 then
    -- This will be handled by the layout engine
  end
  
  -- Clamp to available space
  elementWidth = math.min(elementWidth, availableRect.w)
  elementHeight = math.min(elementHeight, availableRect.h)
  
  -- Apply minimum size constraints
  elementWidth = math.max(elementWidth, element.minWidth or 0)
  elementHeight = math.max(elementHeight, element.minHeight or 0)
  
  return {
    x = availableRect.x,
    y = availableRect.y,
    w = elementWidth,
    h = elementHeight
  }
end

return Measure
