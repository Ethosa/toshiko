# --- Test 10. Anchor setting. --- #
import toshiko


Window("Test 10")

var
  scene = Scene()
  root = Control()
  ctrl = Control()

root.addChild(ctrl)
root.setStyle(style(
  {
    size-anchor: 1,
    background-color: rgb(100, 125, 195)
  }
))

ctrl.resize(128, 64)
ctrl.addChild(ctrl)
ctrl.setStyle(style(
  {
    position-anchor: 0.5,
    background-color: rgb(195, 125, 195)
  }
))

scene.addChild(root)
addMainScene(scene)
showWindow()
