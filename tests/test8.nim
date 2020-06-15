# --- Test 8. Use Drawable and Control. --- #
import toshiko


Window("Test 8")

var
  scene = Scene()
  ctrl = Control()


scene.addChild(ctrl)
env.background_color = Color("#eee")
ctrl.resize(256, 96)
ctrl.move(64, 64)
ctrl.setStyle(style(
  {
    background-color: turquoise,
    border-radius: 8,
    border-width: 1,
    border-color: black
  }
))

addMainScene(scene)
showWindow()
