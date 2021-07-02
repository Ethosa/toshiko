# --- Test 20. Use GridBox object. --- #
import toshiko


Window("Test 20")
setBackgroundColor(Color("#fed"))


build:
  - Scene main:
    - GridBox grid1:
      - ColorRect rect1_1:
        color: Color("#f6f")
      - ColorRect rect1_2:
        color: Color("#d87")
      - ColorRect rect1_3:
        color: Color("#cd7")
      - ColorRect rect1_4:
        color: Color("#f7a")
    - GridBox grid2:
      row: 2  # row count. default value is 3.
      position_anchor: Anchor(1, 0, 1, 0)
      - ColorRect rect2_1:
        color: Color("#f6f")
      - ColorRect rect2_2:
        color: Color("#d87")
      - ColorRect rect2_3:
        color: Color("#cd7")
      - ColorRect rect2_4:
        color: Color("#f7a")

addMainScene(main)
showWindow()
