# --- Test 4. Use Canvas. --- #
import toshiko


Window("Test 4")

var scene = Scene()
var canvas = Canvas()


scene.addChild(canvas)

canvas.fill(Color("#a8f9da"))
canvas.pixel(25, 25, Color("#f6f"))
canvas.line(32, 32, 128, 256, Color("#4aa"))
canvas.rect(32, 128, 128, 256, Color("#a44"))
canvas.circle(256, 256, 64, Color("#64a"), detail = 180)

addMainScene(scene)
showWindow()
