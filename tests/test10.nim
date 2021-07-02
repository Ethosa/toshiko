# --- Test 12. Use TextureRect object. --- #
import toshiko


Window("Test 12", 513, 513)

var
  scene = Scene()
  texture1 = TextureRect()
  texture2 = TextureRect()
  texture3 = TextureRect()

texture1.loadTexture("assets/3.jpg")
texture2.loadTexture("assets/3.jpg")
texture3.loadTexture("assets/3.jpg")

texture1.resize(256, 256)
texture2.resize(256, 256)
texture3.resize(256, 256)

texture1.setTextureMode(TEXTUREMODE_FILL_XY)
texture2.setTextureMode(TEXTUREMODE_CROP)
texture3.setTextureMode(TEXTUREMODE_KEEP_ASPECT_RATIO)

scene.addChilds(texture1, texture2, texture3)

texture2.move(257, 0)
texture3.move(0, 257)

addMainScene(scene)
showWindow()
