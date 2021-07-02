# --- Test 15. Build nodes with YML-like syntax. --- #
import toshiko


Window("Test 15")

build:
  - Scene main:
    name: "hello"
    - ColorRect rect:
      - ColorRect rect1:
        color: Color("#d77")
        rect_position: Vector2(64, 64)

rect1@on_ready(self):
  echo "ready lol :p"

rect1@on_hover(self, x, y):
  rect1.setColor(Color("#84f"))

rect1@on_out(self, x, y):
  rect1.setColor(Color("#d77"))

assert rect1.parent.parent.name == main.name

addMainScene(main)
showWindow()
