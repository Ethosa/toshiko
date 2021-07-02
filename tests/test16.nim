# --- Test 18. Use VBox and HBox objects. --- #
import toshiko

Window("Test 18")

build:
  - Scene main:
    - VBox vbox:
      separator: 4f  # space between children
      - ColorRect vrect1:
        color: Color("#d6f")
      - ColorRect vrect2:
        color: Color("#6fd")
      - ColorRect vrect3:
        color: Color("#fd6")
    - HBox hbox:
      separator: 8f  # space between children
      - ColorRect hrect1:
        color: Color("#d6f")
      - ColorRect hrect2:
        color: Color("#6fd")
      - ColorRect hrect3:
        color: Color("#fd6")

hbox.move(64, 0)

addMainScene(main)
showWindow()
