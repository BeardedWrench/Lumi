local Geom = {}

function Geom.rect(x, y, w, h)
  return {x = x or 0, y = y or 0, w = w or 0, h = h or 0}
end

function Geom.rectFromPoints(x1, y1, x2, y2)
  return {
    x = math.min(x1, x2),
    y = math.min(y1, y2),
    w = math.abs(x2 - x1),
    h = math.abs(y2 - y1)
  }
end

function Geom.pointInRect(px, py, rect)
  return px >= rect.x and px <= rect.x + rect.w and
         py >= rect.y and py <= rect.y + rect.h
end

function Geom.rectsIntersect(rect1, rect2)
  return not (rect1.x + rect1.w < rect2.x or
              rect2.x + rect2.w < rect1.x or
              rect1.y + rect1.h < rect2.y or
              rect2.y + rect2.h < rect1.y)
end

function Geom.rectIntersection(rect1, rect2)
  local x1 = math.max(rect1.x, rect2.x)
  local y1 = math.max(rect1.y, rect2.y)
  local x2 = math.min(rect1.x + rect1.w, rect2.x + rect2.w)
  local y2 = math.min(rect1.y + rect1.h, rect2.y + rect2.h)
  
  if x1 < x2 and y1 < y2 then
    return Geom.rect(x1, y1, x2 - x1, y2 - y1)
  else
    return Geom.rect(0, 0, 0, 0)
  end
end

function Geom.inset(rect, left, top, right, bottom)
  left = left or 0
  top = top or 0
  right = right or left
  bottom = bottom or top
  
  return Geom.rect(
    rect.x + left,
    rect.y + top,
    rect.w - left - right,
    rect.h - top - bottom
  )
end

function Geom.clamp(value, min, max)
  return math.max(min, math.min(max, value))
end

function Geom.clampRect(rect, bounds)
  local x = Geom.clamp(rect.x, bounds.x, bounds.x + bounds.w - rect.w)
  local y = Geom.clamp(rect.y, bounds.y, bounds.y + bounds.h - rect.h)
  return Geom.rect(x, y, rect.w, rect.h)
end

return Geom
