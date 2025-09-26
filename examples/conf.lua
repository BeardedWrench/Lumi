function lovr.conf(t)
  t.window.width = 1920
  t.window.height = 1080
  t.window.title = "Lumi UI - Minimal Panel Test"
  t.window.resizable = true
  
  -- Enable mouse input
  t.headset.drivers = { 'desktop' }
  t.headset.mouse = true
  t.headset.trackers = { 'mouse' }
end
