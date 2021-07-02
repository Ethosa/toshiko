# --- Test 16. Convert JSON string to the Scene. --- #
import toshiko


Window("Test 16")

var
  jsonstring = """{
    "ColorRect": {
        "name": "rect1",
        "color": "#f6f",
        "rect_size": [128, 64],
        "children": [
          {
            "ColorRect": {
              "name": "rect2",
              "color": "pastelgreen"
            }
          }
        ]
      }
  }"""
  scene = json2node(jsonstring)

assert scene.name == "Scene"
assert scene.getNode("rect1/rect2").name == "rect2"

addMainScene(scene)
showWindow()
