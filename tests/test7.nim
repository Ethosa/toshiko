# --- Test 9. Handle Control events. --- #
import toshiko


Window("Test 9")

var
  scene = Scene()
  ctrl = Control()

ctrl.resize(64, 64)
ctrl@on_process(self):
  var s = self.ControlRef
  if s.pressed:
    ctrl.setBackgroundColor(Color("#faa"))
  elif s.hovered:
    ctrl.setBackgroundColor(Color("#aaf"))
  else:
    ctrl.setBackgroundColor(Color("#afa"))

scene.addChild(ctrl)
addMainScene(scene)
showWindow()
