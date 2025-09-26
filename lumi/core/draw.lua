-- Drawing utilities for Lumi UI
-- Handles orthographic projection setup and rendering helpers

local Draw = {}
local Theme = require('lumi.core.theme')

-- Set up orthographic projection for UI rendering
function Draw.setupOrtho(pass, width, height)
  -- Create orthographic projection matrix
  local ortho = lovr.math.mat4():orthographic(0, width, height, 0, -1, 1)
  
  -- Set projection and view
  pass:setProjection(1, ortho)
  pass:setViewPose(1, 0, 0, 0, 0, 0, 0, 1)
  
  -- Note: Depth testing is handled by the render pass setup
end

-- Draw a filled rectangle
function Draw.rect(pass, x, y, w, h, r, g, b, a)
  r = r or 1
  g = g or 1
  b = b or 1
  a = a or 1
  
  pass:setColor(r, g, b, a)
  pass:plane(x + w/2, y + h/2, 0, w, h, 0, 0, 0, 1)
end

-- Draw a rectangle border
function Draw.rectBorder(pass, x, y, w, h, borderWidth, r, g, b, a)
  borderWidth = borderWidth or 1
  r = r or 1
  g = g or 1
  b = b or 1
  a = a or 1
  
  pass:setColor(r, g, b, a)
  
  -- Draw four lines for border
  local points = {
    x, y, 0,
    x + w, y, 0,
    x + w, y + h, 0,
    x, y + h, 0,
    x, y, 0
  }
  
  pass:line(points, borderWidth)
end

-- Draw rounded rectangle (approximated with multiple planes)
function Draw.roundedRect(pass, x, y, w, h, radius, r, g, b, a)
  radius = radius or 0
  r = r or 1
  g = g or 1
  b = b or 1
  a = a or 1
  
  pass:setColor(r, g, b, a)
  
  if radius <= 0 then
    -- Simple rectangle
    Draw.rect(pass, x, y, w, h, r, g, b, a)
    return
  end
  
  -- For now, draw as simple rectangle
  -- TODO: Implement proper rounded rectangles with multiple planes
  Draw.rect(pass, x, y, w, h, r, g, b, a)
end

-- Draw text using LÖVR's built-in alignment
function Draw.text(pass, text, x, y, fontSize, r, g, b, a, align)
  fontSize = fontSize or Theme.typography.fontSize
  r = r or 1
  g = g or 1
  b = b or 1
  a = a or 1
  align = align or 'left'
  
  pass:setColor(r, g, b, a)

  
  -- Use LÖVR's built-in alignment
  local halign = 'left'
  if align == 'center' then
    halign = 'center'
  elseif align == 'right' then
    halign = 'right'
  end
  
  pass:text(text, x, y, 0, fontSize, 0, 0, 0, 0, 0, halign, 'middle')
end

-- Draw icon/image
function Draw.icon(pass, x, y, w, h, iconPath, r, g, b, a)
  r = r or 1
  g = g or 1
  b = b or 1
  a = a or 1
  
  pass:setColor(r, g, b, a)
  
  if iconPath and lovr.graphics.newTexture then
    -- Try to load and draw texture
    local success, texture = pcall(lovr.graphics.newTexture, iconPath)
    if success and texture then
      pass:setMaterial(texture)
      pass:plane(x + w/2, y + h/2, 0, w, h, 0, 0, 0, 1)
      pass:setMaterial()
    else
      -- Fallback: draw colored rectangle
      Draw.rect(pass, x, y, w, h, r, g, b, a)
    end
  else
    -- Fallback: draw colored rectangle
    Draw.rect(pass, x, y, w, h, r, g, b, a)
  end
end

-- Draw shadow
function Draw.shadow(pass, x, y, w, h, shadow)
  if not shadow or not shadow.enabled then
    return
  end
  
  local shadowColor = shadow.color or {0, 0, 0, 0.3}
  local offsetX = shadow.offsetX or 2
  local offsetY = shadow.offsetY or 2
  
  -- Draw shadow rectangle
  Draw.rect(pass, x + offsetX, y + offsetY, w, h, 
    shadowColor[1], shadowColor[2], shadowColor[3], shadowColor[4])
end

-- Draw tooltip background
function Draw.tooltip(pass, x, y, w, h, text, r, g, b, a)
  r = r or 0.05
  g = g or 0.05
  b = b or 0.05
  a = a or 0.95
  
  -- Draw background
  Draw.roundedRect(pass, x, y, w, h, 4, r, g, b, a)
  
  -- Draw border
  Draw.rectBorder(pass, x, y, w, h, 1, 0.3, 0.3, 0.3, 1)
  
  -- Draw text
  if text then
    local padding = Theme.spacing.tooltipPadding
    Draw.text(pass, text, x + padding, y + padding, 
      Theme.typography.fontSizeSmall, 0.9, 0.9, 0.9, 1)
  end
end

return Draw