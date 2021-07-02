# --- Test 19. Use Buttons. --- #
import toshiko


Window("Test 19")
setBackgroundColor(Color("#cba"))

# Note: This function may not be called because the standard font is specified in the global_settings.toshiko file
# setStandardFont("assets/unifont.ttf", 16)  # global setting


build:
  - Scene main:
    - Button btn1
    - Button btn2
    - Button btn3

btn1.setText("Button")
btn1.setBackgroundColor(Color("#235"))
btn1.getBackground().setCornerRadius(4)

btn2.setText("Press me")
btn2.move(0, 41)
btn2.setBackgroundColor(Color("#84f"))
btn2.getHoverBackground().setColor(Color("#f6f"))
btn2.getPressBackground().setColor(Color("#f48"))
btn2.getBackground().setCornerRadius(8)
btn2.getHoverBackground().setCornerRadius(8)
btn2.getPressBackground().setCornerRadius(8)

btn3.setText("Press")
btn3.move(81, 41)
btn3.setBackgroundColor(Color("#325"))

addMainScene(main)
showWindow()
