# author: Ethosa
import
  macros,
  strutils,
  math


type
  NimObjKind* {.pure.} = enum
    NIMOBJECT_VOID,
    NIMOBJECT_BOOLEAN,
    NIMOBJECT_NUMBER,
    NIMOBJECT_STRING,
    NIMOBJECT_ARRAY,
    NIMOBJECT_OBJECT,
    NIMOBJECT_TYPE
  NimObj* = object
    case kind*: NimObjKind
    of NIMOBJECT_BOOLEAN:
      boolean: bool
    of NIMOBJECT_NUMBER:
      integer: int
      floating: float
    of NIMOBJECT_STRING:
      str: string
    of NIMOBJECT_ARRAY:
      arr: seq[NimRef]
    of NIMOBJECT_OBJECT:
      dict: seq[tuple[key, value: NimRef]]
    of NIMOBJECT_TYPE:
      name: string
      attrs: seq[tuple[name: string, value: NimRef]]
    else:
      discard
  NimRef* = ref NimObj


proc nimobj*: NimRef =
  NimRef(kind: NIMOBJECT_VOID)

proc nimobj*(val: bool): NimRef =
  NimRef(kind: NIMOBJECT_BOOLEAN, boolean: val)

proc nimobj*(val: int | float): NimRef =
  NimRef(kind: NIMOBJECT_NUMBER, integer: val.int, floating: val.float)

proc nimobj*(val: string): NimRef =
  NimRef(kind: NIMOBJECT_STRING, str: val)

proc nimobj*(val: seq[NimRef]): NimRef =
  NimRef(kind: NIMOBJECT_ARRAY, arr: val)

proc nimobj*(val: seq[tuple[key, value: NimRef]]): NimRef =
  NimRef(kind: NIMOBJECT_OBJECT, dict: val)

proc nimtype*(name: string = "NimType"): NimRef =
  NimRef(kind: NIMOBJECT_TYPE)


proc `$`*(a: NimRef): string =
  case a.kind
  of NIMOBJECT_BOOLEAN:
    return $a.boolean
  of NIMOBJECT_NUMBER:
    if a.floating.ceil().int != a.integer or a.floating.floor().int != a.integer:
      return $a.floating
    else:
      return $a.integer
  of NIMOBJECT_STRING:
    return "\"" & a.str & "\""
  of NIMOBJECT_ARRAY:
    var r = "["
    for i in a.arr:
      r &= $i & ", "
    if r != "[":
      r = r[0..^3] & "]"
    else:
      r &= "]"
    return r
  of NIMOBJECT_OBJECT:
    var r = "{"
    for i in a.dict:
      r &= $i.key & ": " & $i.value & ", "
    if r != "{":
      r = r[0..^3] & "}"
    else:
      r &= "}"
    return r
  of NIMOBJECT_TYPE:
    return a.name
  else:
    return ""

proc `==`*(a, b: NimRef): bool =
  if a.kind == b.kind:
    case a.kind
    of NIMOBJECT_BOOLEAN:
      return a.boolean == b.boolean
    of NIMOBJECT_NUMBER:
      return a.floating == b.floating
    of NIMOBJECT_STRING:
      return a.str == b.str
    of NIMOBJECT_ARRAY:
      return a.arr == b.arr
    of NIMOBJECT_OBJECT:
      return a.dict == b.dict
    else:
      return true
  return false

proc `+`*(a, b: NimRef): NimRef =
  if a.kind == b.kind:
    case a.kind
    of NIMOBJECT_NUMBER:
      return nimobj(a.floating + b.floating)
    of NIMOBJECT_STRING:
      return nimobj(a.str & b.str)
    of NIMOBJECT_ARRAY:
      var res = a.arr
      for i in b.arr:
        res.add(i)
      return nimobj(res)
    else:
      discard


proc `[]`*(a: NimRef, index: int): NimRef =
  if a.kind == NIMOBJECT_ARRAY:
    return a.arr[index]
  elif a.kind == NIMOBJECT_STRING:
    return nimobj($a.str[index])

proc `[]`*(a: NimRef, index: string): NimRef =
  if a.kind == NIMOBJECT_OBJECT:
    for i in a.dict:
      if i.key.kind == NIMOBJECT_STRING and i.key.str == index:
        return i.value
  elif a.kind == NIMOBJECT_TYPE:
    for i in a.attrs:
      if i.name == index:
        return i.value

proc `[]`*(a, b: NimRef): NimRef =
  if a.kind == NIMOBJECT_OBJECT:
    for i in a.dict:
      if i.key == b:
        return i.value


proc `[]=`*(a: var NimRef, i: int, v: NimRef) =
  if a.kind == NIMOBJECT_ARRAY:
    a.arr[i] = v

proc `[]=`*(a: var NimRef, i, v: NimRef) =
  if a.kind == NIMOBJECT_OBJECT:
    for j in 0..a.dict.high:
      if a.dict[j].key == i:
        a.dict[j].value = v
        return
    a.dict.add((i, v))
  elif a.kind == NIMOBJECT_TYPE and i.kind == NIMOBJECT_STRING:
    for j in 0..a.attrs.high:
      if a.attrs[j].name == i.str:
        a.attrs[j].value = v
        return
    a.attrs.add((i.str, v))

# --- Standard functions --- #
proc add*(a: var NimRef, b: NimRef) =
  if a.kind == NIMOBJECT_ARRAY:
    a.arr.add(b)
  elif a.kind == NIMOBJECT_NUMBER and a.kind == b.kind:
    a.floating += b.floating
    a.integer = a.floating.int

proc len*(a: NimRef): int =
  if a.kind == NIMOBJECT_ARRAY:
    return a.arr.len()

proc pop*(a: var NimRef, index: int = -1): NimRef =
  if a.kind == NIMOBJECT_ARRAY:
    var j = index
    if j == -1:
      j = a.arr.high
    for i in 0..a.arr.high:
      if i == j:
        result = a.arr[i]
        a.arr.delete(i)
        break


# --- Converters --- #
converter string*(a: NimRef): string =
  return $a

converter toInt*(a: NimRef): int =
  if a.kind == NIMOBJECT_NUMBER:
    return a.integer
  elif a.kind == NIMOBJECT_STRING:
    return parseInt(a.str)

converter toFloat*(a: NimRef): float =
  if a.kind == NIMOBJECT_NUMBER:
    return a.floating
  elif a.kind == NIMOBJECT_STRING:
    return parseFloat(a.str)

converter toBool*(a: NimRef): bool =
  if a.kind == NIMOBJECT_BOOLEAN:
    return a.boolean
  elif a.kind == NIMOBJECT_NUMBER:
    return a.floating != 0.0
  elif a.kind == NIMOBJECT_STRING:
    return a.str != ""
  elif a.kind == NIMOBJECT_ARRAY:
    return a.len() > 0
  elif a.kind == NIMOBJECT_OBJECT:
    return a.dict.len > 0
  else:
    return false

converter toNimRef*(a: int | float | string | bool | seq[tuple[key, value: NimRef]] | seq[NimRef]): NimRef =
  nimobj(a)


# --- Macros --- #
proc setNimRef(a: NimNode): NimNode =
  result = a
  case result.kind
  of nnkPrefix:
    for i in 0..<result[1].len():
      result[1][i] = result[1][i].setNimRef()
  of nnkCall:
    for i in 1..<result.len():
      result[i] = result[i].setNimRef()
  else:
    discard
  return newCall("nimobj", result)

macro tonimobj*(a: untyped): untyped =
  result = a
  result = result.setNimRef()

macro `->`*(a: NimRef, attr: untyped): untyped =
  ## This uses in the nim object types.
  ##
  ## ## Example
  ## .. code-block:: nim
  ##
  ##    var mytype = nimtype("MyType")
  ##    mytype.setAttr(test, 123)
  ##    echo mytype->test
  newCall("[]", a, newLit($attr))

macro setAttr*(a: NimRef, attr, value: untyped): untyped =
  ## This uses in the nim object types.
  ##
  ## ## Example
  ## .. code-block:: nim
  ##
  ##    var mytype = nimtype("MyType")
  ##    mytype.setAttr(test, 123)
  newCall("[]=", a, newCall("nimobj", newLit($attr)), newCall("tonimobj", value))

macro class*(a, b: untyped): untyped =
  ## Creates a new NimObject Type.
  ##
  ## ## Example
  ## .. code-block:: nim
  ##
  ##    class A:
  ##      test = 1
  ##      a = "smth here"
  ##      b = @[1, 0.1, false, "..."]
  ##    echo A->b
  result = newStmtList()
  result.add(newNimNode(nnkVarSection))
  result[^1].add(newNimNode(nnkIdentDefs))
  result[^1][0].add(a, newNimNode(nnkEmpty), newCall("nimtype", newLit($a)))
  
  for i in b:
    if i.kind == nnkAsgn:
      result.add(newCall("[]=", a, newCall("nimobj", newLit($i[0])), newCall("tonimobj", i[1])))
