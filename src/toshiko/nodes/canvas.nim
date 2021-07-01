# author: Ethosa
import
  ../core/color,
  ../core/vector2,
  ../core/enums,

  ../thirdparty/opengl,

  node,
  math


type
  DrawCommandType* {.pure.} = enum
    DRAW_PIXEL, DRAW_LINE, DRAW_RECT, DRAW_CIRCLE, DRAW_FILL
  DrawCommand* = object
    x1, y1: float
    case kind: DrawCommandType
    of DRAW_LINE, DRAW_RECT:
      x2, y2: float
    of DRAW_CIRCLE:
      radius: float
      detail: int
    else:
      nil
    color: ColorRef
  CanvasObj* = object of NodeObj
    commands*: seq[DrawCommand]
  CanvasRef* = ref CanvasObj


proc Canvas*(name: string = "Canvas"): CanvasRef =
  ## Creates a new Canvas object.
  nodepattern(CanvasRef)
  result.kind = CANVAS_NODE


method draw*(self: CanvasRef, w, h: float) =
  {.warning[LockLevel]: off.}
  let
    x = -w/2
    y = h/2
  for cmd in self.commands:
    glColor4f(cmd.color.r, cmd.color.g, cmd.color.b, cmd.color.a)
    case cmd.kind
    of DRAW_PIXEL:
      glBegin(GL_POINTS)
      glVertex2f(x + cmd.x1, y - cmd.y1)
    of DRAW_LINE:
      glBegin(GL_LINES)
      glVertex2f(x + cmd.x1, y - cmd.y1)
      glVertex2f(x + cmd.x2, y - cmd.y2)
    of DRAW_RECT:
      glBegin(GL_QUADS)
      glVertex2f(x + cmd.x1, y - cmd.y1)
      glVertex2f(x + cmd.x2, y - cmd.y1)
      glVertex2f(x + cmd.x2, y - cmd.y2)
      glVertex2f(x + cmd.x1, y - cmd.y2)
    of DRAW_FILL:
      glBegin(GL_QUADS)
      glVertex2f(x, y)
      glVertex2f(x + w, y)
      glVertex2f(x + w, y - h)
      glVertex2f(x, y - h)
    of DRAW_CIRCLE:
      glBegin(GL_TRIANGLE_FAN)
      glVertex2f(x + cmd.x1, y - cmd.y1)
      for i in 0..cmd.detail:
        let angle = TAU * (i / cmd.detail)
        glVertex2f(x + cmd.x1 + cmd.radius*cos(angle), y - cmd.y1 - cmd.radius*sin(angle))
    glEnd()

method fill*(self: CanvasRef, color: ColorRef) {.base.} =
  self.commands = @[DrawCommand(kind: DRAW_FILL, color: color)]

method line*(self: CanvasRef, x1, y1, x2, y2: float, color: ColorRef) {.base.} =
  self.commands.add(DrawCommand(kind: DRAW_LINE, x1: x1, y1: y1, x2: x2, y2: y2, color: color))

method pixel*(self: CanvasRef, x, y: float, color: ColorRef) {.base.} =
  self.commands.add(DrawCommand(kind: DRAW_PIXEL, x1: x, y1: y, color: color))

method rect*(self: CanvasRef, x1, y1, x2, y2: float, color: ColorRef) {.base.} =
  self.commands.add(DrawCommand(kind: DRAW_RECT, x1: x1, y1: y1, x2: x2, y2: y2, color: color))

method circle*(self: CanvasRef, cx, cy, r: float, color: ColorRef, detail: int = 180) {.base.} =
  self.commands.add(DrawCommand(kind: DRAW_CIRCLE, x1: cx, y1: cy, color: color, radius: r, detail: detail))
