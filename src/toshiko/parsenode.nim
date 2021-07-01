# author: Ethosa
## Provides JSON to Node.
import
  json,
  parsejson,
  xmlparser,
  xmltree,
  strtabs,
  tables,
  strutils,
  nodes,
  control,
  core


var parsable_nodes = initTable[system.string, proc(name: string = "Node"): NodeRef]()


template loadjsonnode(fn: untyped): untyped =
  if level.len() > 0:
    level[^1].addChild(`fn`())
    if value.kind == JObject:
      level.add(level[^1].children[^1])
      addJsonNode(level, value)

template loadxmlnode(fn: untyped): untyped =
  if level.len() > 0:
    level[^1].addChild(`fn`())

template loadvalue(statement: untyped): untyped =
  if level.len() > 0:
    `statement`

template loadnode(fn, key: untyped): untyped =
  case `key`
  of "Node":
    `fn`(Node)
  of "Scene":
    `fn`(Scene)
  of "Canvas":
    `fn`(Canvas)
  of "AudioStreamPlayer":
    `fn`(AudioStreamPlayer)

  # Control nodes
  of "Control":
    `fn`(Control)
  of "ColorRect":
    `fn`(ColorRect)
  of "TextureRect":
    `fn`(TextureRect)
  of "Label":
    `fn`(Label)
  of "Box":
    `fn`(Box)
  of "HBox":
    `fn`(HBox)
  of "VBox":
    `fn`(VBox)
  of "Button":
    `fn`(Button)
  of "GridBox":
    `fn`(GridBox)
  of "ProgressBar":
    `fn`(ProgressBar)
  else:
    if parsable_nodes.hasKey(`key`):
      `fn`(parsable_nodes[`key`])

template loadval(fn, get_float_func, get_string_func, float_array: untyped) =
  ## load value from XML or JSON.
  ##
  ## Arguments:
  ## - `fn` is a load value function.
  ## - `get_float_func` is a function, which should return `float`.
  ## - `get_string_func` is a function, which should return `string`.
  ## - `float_array` is a statement which should be float/string array.
  case key
  # properties
  of "name":
    `fn`:
      level[^1].name = `get_string_func`(value)
  of "color":
    `fn`(level[^1].ColorRectRef.setColor(Color(`get_string_func`(value))))
  of "background_color":
    `fn`(level[^1].ControlRef.setBackgroundColor(Color(`get_string_func`(value))))
  of "position_anchor":
    let tmp = `float_array`
    `fn`(level[^1].ControlRef.setAnchor(Anchor(
      `get_float_func`(tmp[0]), `get_float_func`(tmp[1]), `get_float_func`(tmp[2]), `get_float_func`(tmp[3])
    )))
  of "rect_size":
    let tmp = `float_array`
    `fn`(level[^1].ControlRef.resize(`get_float_func`(tmp[0]), `get_float_func`(tmp[1])))
  of "rect_position":
    let tmp = `float_array`
    `fn`(level[^1].ControlRef.move(`get_float_func`(tmp[0]), `get_float_func`(tmp[1])))
  of "text":
    if level[^1].kind == LABEL_NODE:
      `fn`(level[^1].LabelRef.setText(`get_string_func`(value)))
    elif level[^1].kind == BUTTON_NODE:
      `fn`(level[^1].ButtonRef.setText(`get_string_func`(value)))
  of "texture":
    `fn`(level[^1].TextureRectRef.loadTexture(`get_string_func`(value)))
  of "size_anchor":
    let tmp = `float_array`
    `fn`(level[^1].ControlRef.setSizeAnchor(Vector2(`get_float_func`(tmp[0]), `get_float_func`(tmp[1]))))
  of "stream":
    `fn`(level[^1].AudioStreamPlayerRef.setStream(`get_string_func`(value)))
  of "cell_size":
    let tmp = `float_array`
    `fn`(level[^1].GridBoxRef.setCellSize(Vector2(`get_float_func`(tmp[0]), `get_float_func`(tmp[1]))))
  of "row":
    let tmp = `float_array`
    `fn`(level[^1].GridBoxRef.setRow(`get_float_func`(tmp[0]).int))
  of "style":
    `fn`(level[^1].ControlRef.setStyle(StyleSheet(`get_string_func`(value))))
  else:
    discard


proc toStr(node: JsonNode): string =
  if node.kind == JString:
    return node.getStr
  else:
    return $node

proc addJsonNode(level: var seq[NodeRef], jobj: JsonNode) =
  for key, value in jobj.pairs():
    # Default nodes
    loadnode(loadjsonnode, key)
    # Properties
    loadval(loadvalue, getFloat, toStr, value)

    # childs
    if key == "children":
      if value.kind == JArray:
        for i in value.items():
          addJsonNode(level, i)
    else:
      discard
  if level.len() > 0:
    discard level.pop()


proc addXmlNode(level: var seq[NodeRef], xml: XmlNode) =
  # nodes
  loadnode(loadxmlnode, xml.tag)
  level.add(level[^1].children[^1])

  # properties
  if not xml.attrs.isNil():
    for key, value in xml.attrs.pairs:
      loadval(loadvalue, parseFloat, `$`, value.split(Whitespace))

  # children
  for child in xml.items():
    addXmlNode(level, child)

  if level.len() > 0:
    discard level.pop()

proc json2node*(src: string): SceneRef =
  ## Converts JSON string to the new Scene object.
  ##
  ## Arguments:
  ## - `src` is a source JSON string.
  result = Scene()
  var
    jobj = parseJson(src)
    level: seq[NodeRef] = @[]
  level.add(result)
  addJsonNode(level, jobj)

proc xml2node*(src: string): SceneRef =
  ## COnverts XML string to he new Scene object.
  ##
  ## Arguments:
  ## - `src` is a source XML string.
  result = Scene()
  var
    jobj = parseXml(src)
    level: seq[NodeRef] = @[]
  level.add(result)
  addXmlNode(level, jobj)

proc xmlfile2node*(src: string): SceneRef =
  ## COnverts XML string to he new Scene object.
  ##
  ## Arguments:
  ## - `src` is a source XML string.
  result = Scene()
  var
    jobj = loadXml(src)
    level: seq[NodeRef] = @[]
  level.add(result)
  addXmlNode(level, jobj)

proc makeParsable*(nodefunc: proc(name: string = "Node"): NodeRef, str: system.string) =
  ## Makes node parselable.
  ##
  ## Arguments:
  ## - `nodefunc` is a Node constructor.
  ## - `str` is a Node string.
  ##
  ## Example:
  ##
  ## .. code-block:: nim
  ##
  ##    makeParsable(addr MyOwnNode, "MyOwnNode")
  parsable_nodes[str] = nodefunc

proc loadScene*(file: string): SceneRef =
  ## Loads a new Scene object from JSON or XML file.
  ##
  ## Arguments:
  ## - `file` is a JSON/XML file path.
  var
    f = open(file, fmRead)
    readed = f.readAll()
  f.close()
  try:
    result = json2node(readed)
  except JsonParsingError:
    result = xml2node(readed)
  except XmlError:
    when defined(debug):
      echo "file \"" & file & "\" not contains XML or JSON."
    result = Scene()
