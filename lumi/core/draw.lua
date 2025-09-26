local Draw = {}
local Theme = require('lumi.core.theme')


function Draw.setupOrtho(pass, width, height)
  
  local ortho = lovr.math.mat4():orthographic(0, width, height, 0, -1, 1)
  
  
  pass:setProjection(1, ortho)
  pass:setViewPose(1, 0, 0, 0, 0, 0, 0, 1)
  
  
end


function Draw.rect(pass, x, y, w, h, r, g, b, a)
  r = r or 1
  g = g or 1
  b = b or 1
  a = a or 1
  
  pass:setColor(r, g, b, a)
  pass:plane(x + w/2, y + h/2, 0, w, h, 0, 0, 0, 1)
end


function Draw.rectBorder(pass, x, y, w, h, borderWidth, r, g, b, a)
  borderWidth = borderWidth or 1
  r = r or 1
  g = g or 1
  b = b or 1
  a = a or 1
  
  pass:setColor(r, g, b, a)
  
  
  local points = {
    x, y, 0,
    x + w, y, 0,
    x + w, y + h, 0,
    x, y + h, 0,
    x, y, 0
  }
  
  pass:line(points, borderWidth)
end


function Draw.roundedRect(pass, x, y, w, h, radius, r, g, b, a)
  radius = radius or 0
  r = r or 1
  g = g or 1
  b = b or 1
  a = a or 1
  
  pass:setColor(r, g, b, a)
  
  if radius <= 0 then
    
    Draw.rect(pass, x, y, w, h, r, g, b, a)
    return
  end
  
  
  
  Draw.rect(pass, x, y, w, h, r, g, b, a)
end


function Draw.text(pass, text, x, y, fontSize, r, g, b, a, align)
  fontSize = fontSize or Theme.typography.fontSize
  r = r or 1
  g = g or 1
  b = b or 1
  a = a or 1
  align = align or 'left'
  
  pass:setColor(r, g, b, a)

  
  
  local halign = 'left'
  if align == 'center' then
    halign = 'center'
  elseif align == 'right' then
    halign = 'right'
  end
  
  pass:text(text, x, y, 0, fontSize, 0, 0, 0, 0, 0, halign, 'middle')
end


function Draw.icon(pass, x, y, w, h, iconPath, r, g, b, a)
  r = r or 1
  g = g or 1
  b = b or 1
  a = a or 1
  
  pass:setColor(r, g, b, a)
  
  if iconPath and lovr.graphics.newTexture then
    
    local success, texture = pcall(lovr.graphics.newTexture, iconPath)
    if success and texture then
      pass:setMaterial(texture)
      pass:plane(x + w/2, y + h/2, 0, w, h, 0, 0, 0, 1)
      pass:setMaterial()
    else
      
      Draw.rect(pass, x, y, w, h, r, g, b, a)
    end
  else
    
    Draw.rect(pass, x, y, w, h, r, g, b, a)
  end
end


function Draw.shadow(pass, x, y, w, h, shadow)
  if not shadow or not shadow.enabled then
    return
  end
  
  local shadowColor = shadow.color or {0, 0, 0, 0.3}
  local offsetX = shadow.offsetX or 2
  local offsetY = shadow.offsetY or 2
  
  
  Draw.rect(pass, x + offsetX, y + offsetY, w, h, 
    shadowColor[1], shadowColor[2], shadowColor[3], shadowColor[4])
end


function Draw.tooltip(pass, x, y, w, h, text, r, g, b, a)
  r = r or 0.05
  g = g or 0.05
  b = b or 0.05
  a = a or 0.95
  
  
  Draw.roundedRect(pass, x, y, w, h, 4, r, g, b, a)
  
  
  Draw.rectBorder(pass, x, y, w, h, 1, 0.3, 0.3, 0.3, 1)
  
  
  if text then
    local padding = Theme.spacing.tooltipPadding
    Draw.text(pass, text, x + padding, y + padding, 
      Theme.typography.fontSizeSmall, 0.9, 0.9, 0.9, 1)
  end
end

return Draw