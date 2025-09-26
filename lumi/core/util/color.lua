local Color = {}

function Color.toHex(r, g, b, a)
  a = a or 1
  return string.format("#%02x%02x%02x%02x", 
    math.floor(r * 255), 
    math.floor(g * 255), 
    math.floor(b * 255), 
    math.floor(a * 255))
end

function Color.fromHex(hex)
  hex = hex:gsub("#", "")
  local r = tonumber(hex:sub(1, 2), 16) / 255
  local g = tonumber(hex:sub(3, 4), 16) / 255
  local b = tonumber(hex:sub(5, 6), 16) / 255
  local a = hex:len() > 6 and (tonumber(hex:sub(7, 8), 16) / 255) or 1
  return r, g, b, a
end

function Color.blend(r1, g1, b1, a1, r2, g2, b2, a2, alpha)
  alpha = alpha or 0.5
  local inv_alpha = 1 - alpha
  return r1 * alpha + r2 * inv_alpha,
         g1 * alpha + g2 * inv_alpha,
         b1 * alpha + b2 * inv_alpha,
         a1 * alpha + a2 * inv_alpha
end

function Color.darken(r, g, b, a, factor)
  factor = factor or 0.2
  return r * (1 - factor), g * (1 - factor), b * (1 - factor), a
end

function Color.lighten(r, g, b, a, factor)
  factor = factor or 0.2
  return r + (1 - r) * factor, g + (1 - g) * factor, b + (1 - b) * factor, a
end

return Color
