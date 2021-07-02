# --- Test 17. Convert XML string to the Scene. --- #
import toshiko


Window("Test 17")

var
  xmlstr = """<Node>
    <ColorRect name="Hello" color="#f6f" rect_size="128 64">
      <ColorRect color="turquoise">
      </ColorRect>
    </ColorRect>
  </Node>"""
  scene = xml2node(xmlstr)
scene.addChild(xmlfile2node("xml.xml"))

assert scene.name == "Scene"
assert scene.getNode("Node/Hello").name == "Hello"

addMainScene(scene)
showWindow()
