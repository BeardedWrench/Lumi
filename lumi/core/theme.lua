local Theme = {}
Theme.colors = {
  background = {0.1, 0.1, 0.1, 0.9},
  panel = {0.15, 0.15, 0.15, 0.95},
  button = {0.2, 0.2, 0.2, 1.0},
  input = {0.1, 0.1, 0.1, 1.0},
  
  text = {0.9, 0.9, 0.9, 1.0},
  textSecondary = {0.7, 0.7, 0.7, 1.0},
  textDisabled = {0.4, 0.4, 0.4, 1.0},
  
  border = {0.3, 0.3, 0.3, 1.0},
  borderHover = {0.5, 0.5, 0.5, 1.0},
  borderFocus = {0.2, 0.6, 1.0, 1.0},
  
  hover = {0.4, 0.4, 0.4, 1.0},
  press = {0.1, 0.1, 0.1, 1.0},
  disabled = {0.2, 0.2, 0.2, 0.5},
  
  primary = {0.2, 0.6, 1.0, 1.0},
  success = {0.2, 0.8, 0.2, 1.0},
  warning = {1.0, 0.6, 0.2, 1.0},
  error = {1.0, 0.2, 0.2, 1.0},
  
  tooltip = {0.05, 0.05, 0.05, 0.95},
  tooltipText = {0.9, 0.9, 0.9, 1.0}
}

Theme.spacing = {
  padding = 8,
  margin = 4,
  gap = 8,
  borderWidth = 1,
  borderRadius = 4,
  titlebarHeight = 24,
  scrollbarWidth = 12,
  tooltipPadding = 6,
  tooltipMaxWidth = 200
}

Theme.typography = {
  fontSize = 16,        
  fontSizeSmall = 12,   
  fontSizeLarge = 18,   
  lineHeight = 1.2
}

Theme.animation = {
  tooltipDelay = 0.5, 
  transitionSpeed = 0.2 
}

Theme.shadows = {
  enabled = true,
  offsetX = 2,
  offsetY = 2,
  blur = 4,
  color = {0, 0, 0, 0.3}
}

Theme.zLayers = {
  background = 0,
  content = 100,
  overlay = 200,
  tooltip = 300,
  modal = 400
}

function Theme.set(overrides)
  local function deepMerge(target, source)
    for key, value in pairs(source) do
      if type(value) == "table" and type(target[key]) == "table" then
        deepMerge(target[key], value)
      else
        target[key] = value
      end
    end
  end
  
  deepMerge(Theme, overrides)
end

return Theme
