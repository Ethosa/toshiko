# --- Test 11. Use Image in Drawable. --- #
import toshiko


Window("Test 11")

var
  scene = Scene()
  image = load("assets/1.jpg")
  rect = ColorRect()

scene.addChild(rect)

rect.getBackground().setTexture(image)
rect.resize(256, 128)
rect.move(64, 64)
rect.setStyle(style(
  {
    border-radius: 8
  }
))

addMainScene(scene)
showWindow()
