# --- Test 14. Use Box object. --- #
import toshiko


Window("Test 14")

var
  scene = Scene()
  box1 = Box()
  rect1 = ColorRect()
  rect2 = ColorRect()
  rect3 = ColorRect()

rect1.setColor(Color("#f6f"))
rect2.setColor(Color("#66f"))
rect3.setColor(Color("#f66"))

rect1.resize(128, 128)
rect2.resize(64, 64)
rect3.resize(32, 32)

box1.addChilds(rect1, rect2, rect3)
var
  box2 = box1.duplicate()
  box3 = box1.duplicate()
  box4 = box1.duplicate()

scene.addChilds(box1, box2, box3, box4)

box2.move(129, 0)
box3.move(0, 129)
box4.move(129, 129)

box1.setChildAnchor(Anchor(0.5, 0.5, 0.5, 0.5))
box2.setChildAnchor(Anchor(1, 0, 1, 0))
box3.setChildAnchor(Anchor(0, 1, 0, 1))
box4.setChildAnchor(Anchor(1, 1, 1, 1))

addMainScene(scene)
showWindow()
