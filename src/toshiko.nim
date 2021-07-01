import
  toshiko/thirdparty,
  toshiko/window,
  toshiko/environment,
  toshiko/core,
  toshiko/nodes,
  toshiko/graphics,
  toshiko/control,
  toshiko/parsenode,
  os,
  parsecfg,
  strutils

export
  window, environment, core, nodes, thirdparty,
  graphics, control, parsenode


# Read config
if fileExists("global_settings.toshiko"):
  var
    cfg = loadConfig("global_settings.toshiko")
    w: cint = 640
    h: cint = 360

  setStandardFont(
    cfg.getSectionValue("GUI", "standard-font").cstring,
    parseInt(cfg.getSectionValue("GUI", "standard-font-size")).cint
  )

  if cfg.getSectionValue("Window", "width") != "":
    w = parseInt(cfg.getSectionValue("Window", "width")).cint
  if cfg.getSectionValue("Window", "height") != "":
    h = parseInt(cfg.getSectionValue("Window", "height")).cint

  if w < 32:
    w = 32
  if h < 120:
    h = 120

  if cfg.getSectionValue("Window", "title") != "":
    Window(cfg.getSectionValue("Window", "title").cstring, w, h)

  if cfg.getSectionValue("Window", "icon") != "":
    setIcon(cfg.getSectionValue("Window", "icon").cstring)
