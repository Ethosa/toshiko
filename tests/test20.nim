# --- Test 22. Make parsable your own nodes. --- #
import toshiko


type
  MyOwnNodeObj* = object of NodeObj
  MyOwnNodeRef* = ref MyOwnNodeObj

proc MyOwnNode*(name: string = "MyOwnNode"): NodeRef =
  nodepattern(MyOwnNodeRef)

makeParsable(MyOwnNode, "MyOwnNode")

assert xml2node("<MyOwnNode name=\"lol\"/>").getNode("lol").name == "lol"
