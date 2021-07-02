# --- Test 13. Use Label object --- #
import toshiko


Window("Test 13")

# Note: This function may not be called because the standard font is specified in the global_settings.toshiko file
# setStandardFont("assets/unifont.ttf", 16)  # global setting

var
  scene = Scene()
  label = Label()

scene.addChild(label)
label.setText("Hello, world!")
label.resize(256, 128)
label.setStyle(style(
  {
    color: rgb(111, 174, 245),
    background-color: rgba(240, 240, 240, 0.3),
    border-radius: 8,
    text-align: center
  }
))
addMainScene(scene)
showWindow()
