# author: Ethosa
import
  strutils,
  ../core/enums,
  ../core/input


type
  NodeHandler* = proc(self: NodeRef): void
  NodeInputHandler* = proc(self: NodeRef, event: InputEvent)
  NodeObj* = object of RootObj
    is_ready*: bool
    visible*: bool
    name*: string
    kind*: NodeKind
    nodetype*: NodeType
    pausemode*: PauseMode
    parent*: NodeRef
    children*: seq[NodeRef]

    # handlers
    on_enter*: NodeHandler  ## Called, when entered in the scene.
    on_exit*: NodeHandler  ## Called, when exited from the scene.
    on_ready*: NodeHandler  ## Called after `on_enter`.
    on_process*: NodeHandler  ## Called every tick.
    on_input*: NodeInputHandler
  NodeRef* = ref NodeObj

var
  standard_handler*: NodeHandler = proc(self: NodeRef) = discard
  standard_input_handler*: NodeInputHandler = proc(self: NodeRef, event: InputEvent) = discard


template nodepattern*(t: untyped) =
  result = `t`()
  result.is_ready = false
  result.visible = true
  result.name = name
  result.children = @[]
  result.nodetype = NODETYPE_DEFAULT
  result.pausemode = PAUSE_MODE_INHERIT

  result.on_enter = standard_handler
  result.on_exit = standard_handler
  result.on_ready = standard_handler
  result.on_process = standard_handler

  result.on_input = standard_input_handler


proc Node*(name: string = "Node"): NodeRef =
  ## Creates a new Node object.
  ##
  ## Arguments:
  ## - `name` is a node name.
  runnableExamples:
    var test_node = Node("My node")
  nodepattern(NodeRef)
  result.kind = NODE_NODE


method draw*(self: NodeRef, w, h: float) {.base.} = discard
method handle*(self: NodeRef, event: InputEvent, mouse_on: var NodeRef) {.base.} = discard


method addChild*(self, child: NodeRef) {.base.} =
  ## Adds a new child.
  if self == child:
    return
  self.children.add(child)
  child.parent = self

method addChilds*(self: NodeRef, childs: varargs[NodeRef]) {.base.} =
  ## Adds one or more childs.
  for child in childs:
    self.addChild(child)

template duplicate*(self: NodeRef): untyped =
  ## Duplicates Node object.
  ## It is an alias for deepCopy proc.
  self.deepCopy()

method getAllChilds*(self: NodeRef): seq[NodeRef] {.base.} =
  runnableExamples:
    var
      root = Node()
      child1 = Node()
      child2 = Node()
      child1_1 = Node()
      child2_1 = Node()
      child2_2 = Node()
    root.addChilds(child1, child2)
    child2.addChilds(child2_1, child2_2)
    child1.addChild(child1_1)
    assert root.getAllChilds == @[child1, child1_1, child2, child2_1, child2_2]
  result = @[]
  for child in self.children:
    if child notin result:
      result.add(child)
    if child.children.len() > 0:
      for node in child.getAllChilds():
        if node notin result:
          result.add(node)

method getChild*(self: NodeRef, index: int): NodeRef {.base.} =
  ## Gets child at specific position.
  self.children[index]

method getChildCount*(self: NodeRef): int {.base.} =
  return self.children.len()

method getChildPosition*(self, other: NodeRef): int {.base.} =
  ## Returns `other` position.
  for i in 0..self.children.high:
    if other == self.children[i]:
      return i

method getNode*(self: NodeRef, path: string): NodeRef {.base.} =
  ## Gets node by it name.
  result = self
  var p = path.split("/")

  for part in p:
    case part
    of "..":
      if result.parent != nil:
        result = result.parent
    else:
      for child in result.children:
        if child.name == part:
          result = child
          break

method getParent*(self: NodeRef): NodeRef {.base.} =
  ## Returns parent node, if available.
  if self.parent != nil:
    return self

method getPath*(self: NodeRef): string {.base.} =
  ## Returns full node path.
  var current = self
  result = self.name
  while current.parent != nil:
    current = current.parent
    result = current.name & "/" & result

method getPauseMode*(self: NodeRef): PauseMode {.base.} =
  result = self.pausemode
  var current = self

  while result == PAUSE_MODE_INHERIT and current.parent != nil:
    current = current.parent
    result = current.pausemode

  if result == PAUSE_MODE_INHERIT:
    result = PAUSE_MODE_PAUSE

method getRoot*(self: NodeRef): NodeRef {.base.} =
  ## Returns root node.
  result = self
  while result.parent != nil:
    result = result.parent

method hasNode*(self: NodeRef, name: string): bool {.base.} =
  ## Returns true, when node with name `name` in the `self` children.
  for child in self.children:
    if child.name == name:
      return true
  return false

method hasNode*(self, other: NodeRef): bool {.base.} =
  ## Returns true, when `other` in the `self` children.
  for child in self.children:
    if child == other:
      return true
  return false

method hasParent*(self: NodeRef): bool {.base.} =
  ## Returns true, when `self` has parent node.
  return self.parent != nil

method isParentOf*(self, other: NodeRef): bool {.base.} =
  ## Returns true, when `self` is a parent of `other`.
  return other in self.children

method remove*(self, other: NodeRef) {.base.} =
  ## Removes `other` from children, if available.
  for i in 0..self.children.high:
    if other == self.children[i]:
      self.children.delete(i)
      break


# --- Operators --- #
proc `~`*(self: NodeRef, path: string): NodeRef =
  ## Alias for `getNode <#getNode.e,NodeRef,string>`_ method.
  runnableExamples:
    var test_node = Node()
    discard test_node ~ "../../../hello"
  self.getNode(path)

proc contains*(self, other: NodeRef): bool =
  ## Alias for `hasNode <#hasNode.e,NodeRef,NodeRef>`_ method.
  runnableExamples:
    var test_node = Node()
    assert not (Node() in test_node)
  self.hasNode(other)


# --- Macros --- #
import macros


macro `@`*(node: NodeRef, callable, code: untyped): untyped =
  ## Convenient alias for handlers.
  ##
  ## ## Example
  ## .. code-block:: nim
  ##
  ##    var node = Node()
  ##    node@on_enter(self):
  ##      echo self.name
  # Gets event name.
  if callable.kind == nnkCall:
    case $callable[0]
    of "on_process", "on_ready", "on_enter", "on_exit":
      var
        name = callable[0]
        self = callable[1]
      result = quote do:
        `node`.`name` =
          proc(`self`: NodeRef): void =
            `code`
    of "on_input":
      var
        name = callable[0]
        self = callable[1]
        event = callable[2]
      result = quote do:
        `node`.`name` =
          proc(`self`: NodeRef, `event`: InputEvent): void =
            `code`
    of "on_hover", "on_out", "on_click", "on_press", "on_focus", "on_unfocus", "on_release":
      var
        name = callable[0]
        self = callable[1]
        x = callable[2]
        y = callable[3]
      result = quote do:
        `node`.`name` =
          proc(`self`: ControlRef, `x`, `y`: float): void =
            `code`
    of "on_touch":
      var
        name = callable[0]
        self = callable[1]
        x = callable[2]
        y = callable[3]
      result = quote do:
        `node`.`name` =
          proc(`self`: ButtonRef, `x`, `y`: float): void =
            `code`
    else:
      discard


proc addNode(level: var seq[NimNode], code: NimNode): NimNode {.compileTime.} =
  result = newStmtList()
  if code.kind == nnkStmtList:
    for line in code.children():
      if line.kind == nnkPrefix:
        if line[0].kind == nnkIdent and line[1].kind == nnkCommand:
          if $line[0] == "-":
            result.add(newVarStmt(line[1][1], newCall($line[1][0])))
            if level.len() > 0:
              result.add(newCall("addChild", level[^1], line[1][1]))
      elif line.kind == nnkCall and level.len() > 0:
        var attr = newNimNode(nnkAsgn)
        attr.add(newNimNode(nnkDotExpr))
        attr[0].add(level[^1])
        attr[0].add(line[0])
        attr.add(line[1])
        result.add(attr)
      if len(line) == 3 and line[2].kind == nnkStmtList and line[1].kind == nnkCommand:
        level.add(line[1][1])
        var nodes = addNode(level, line[2])
        for i in nodes.children():
          result.add(i)
    if level.len() > 0:
      discard level.pop()


macro build*(code: untyped): untyped =
  ## Builds nodes with YML-like syntax.
  result = newStmtList()
  var
    current_level: seq[NimNode] = @[]
    nodes = addNode(current_level, code)
  for i in nodes.children():
    result.add(i)
