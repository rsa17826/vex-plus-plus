import fs from "fs"
import sds from "file://C:/Users/User/Desktop/sds/sds.js"
const SCALE = 100
Object.assign(globalThis, console)
var arr = [
  166, 317, -725, -473, 8, 133, 319, 59.85, 4, 839, 115, 400, 250, 4,
  1235, 112, 400, 250, 3, 636, 155, 100, 100, 11, 636, 435, 100, 100,
  28, 714, 414, 41, 637, 412, 5, 675, 443, 10, 636, 438, 100, 100, 0,
  1674, 245, 400.15, 100, 8, 1829, 75, 56.85, 20, 1900, -488, 180, 20,
  1750, -425, 180, 43, 1009, 246, 180, 43, 1424, 232, 180, 34, 1892,
  -361, 35, 98, -458, 20, 2044, -406, 180, 16, 251, -505, 100, 5, 88,
  -382, 42, 38, -409, 399.7, 100, 16, 354, -607, 100, 16, 458, -712,
  100, 16, 559, -814, 100, 24, 291, -852, 80, 24, 483, -1058, 80, 16,
  659, -914, 100, 16, 759, -1014, 100, 16, 859, -1114, 100, 16, 959,
  -1214, 100, 16, 1059, -1314, 100, 16, 1359, -1614, 100, 16, 1159,
  -1217, 100, 16, 1259, -1117, 100, 16, 1359, -1017, 100, 16, 1459,
  -917, 100, 16, 1559, -817, 100, 24, 665, -1249, 80, 24, 883, -1405,
  80, 24, 1349, -1399, 80, 24, 1546, -1251, 80, 36, 1634, -837, 42,
  -361, -405, 400.15, 100, 14, -43, -798, 100, 400, 15, -147, -502,
  100, 100, 15, -359, -503, 100, 100, 15, -260, -609, 100, 100, 15,
  -151, -717, 100, 100, 3, -122, -619, 40, 40, 3, -190, -506, 40, 40,
  5, 1090, -1312, 42, -761, -405, 400, 100, 24, -521, -764, 180, 7,
  1710, 197, -45, 7, 1794, 151, 0, 36, 1765, 203, 1, 0, 0,
]
var playerPos = [arr[0], arr[1]]
var endPos = [arr[2], arr[3]]
arr.splice(0, 4)
arr.splice(-3, 3)
var blocks = []
blocks.push(
  { x: playerPos[0], y: playerPos[1] },
  {
    x: endPos[0],
    y: endPos[1],
    w: 1,
    h: 1,
    id: "goal",
    r: 0,
  }
)
log(playerPos, endPos, arr)
while (arr.length) {
  function xywh([x, y, w, h]) {
    return { x: x + w / 2, y: y + h / 2, w, h }
  }
  function xy([x, y]) {
    return { x: x, y: y, w: 100, h: 100 }
  }
  function xyr([x, y, r]) {
    return { x, y, r, w: 100, h: 100 }
  }
  function xysr([x, y, s, r]) {
    return { x, y, r, w: s, h: s }
  }
  function xys([x, y, s]) {
    return { x: x + s / 2, y: y + s / 2, w: s, h: s }
  }
  var [name, count, func] = (() => {
    switch (arr[0]) {
      case 11:
        return ["leftright", 4, xywh]
      case 0:
        return ["basic", 4, xywh]
      case 3:
        return ["falling", 4, xywh]
      case 42:
        return ["microwave", 4, xywh]
      case 9:
        return ["downup", 4, xywh]
      case 4:
        return ["water", 4, xywh]
      case 14:
        return ["locked box", 4, xywh]
      case 15:
        return ["pushable box", 4, xywh]
      case 17:
        return ["solar", 4, xywh]
      case 18:
        return ["invisible", 4, xywh]
      case 45:
        return ["spark block/clockwise", 4, xywh]
      case 10:
        return ["updown", 4, xywh]
      case 13:
        return ["basic", 4, xywh] // ice
      case 5:
        return ["checkpoint", 2, xy]
      case 40:
        return ["pulley", 2, xy]
      case 26:
        return ["targeting laser", 2, xy]
      case 46:
        return ["pole quadrant", 2, xy]
      case 44:
        return ["laser", 2, xy]
      case 30:
        return ["cannon", 2, xy]
      case 29:
        return ["pole", 2, xy]
      case 41:
        return ["gravity down lever", 2, xy]
      case 28:
        return ["gravity up lever", 2, xy]
      case 12:
        return ["/penjulum", 2, xy]
      case 36:
        return ["key", 2, xy]
      case 38:
        return ["speed up lever", 2, xy]
      case 39:
        return ["red only light switch", 2, xy]
      case 34:
        return [
          "portal",
          2,
          ([x, y]) => {
            return { x, y, options: { exitId: 1 } }
          },
        ]
      case 35:
        return [
          "portal",
          2,
          ([x, y]) => {
            return { x, y, options: { portalId: 1 } }
          },
        ]
      case 1:
        return ["slope", 3, xys]
      case 31:
        return ["breath refresher", 3, xyr]
      case 2:
        return [
          "slope",
          3,
          ([x, y, s]) => {
            return { x: x + s / 2, y: y + s / 2, w: s, h: s, r: 270 }
          },
        ]
      case 8:
        return ["bouncy", 3, xys]
      case 24:
        return ["bouncing buzzsaw", 3, xys]
      case 43:
        return ["growing buzzsaw", 3, xys]
      case 6:
        return ["single spike", 3, xyr]
      case 25:
        return ["closing spikes", 3, xyr]
      case 27:
        return ["rotating buzzsaw", 3, xyr]
      case 33:
        return ["big fan", 3, xyr]
      case 32:
        return ["small fan", 3, xyr]
      case 7:
        return ["10x spike", 3, xyr]
      case 19:
        return ["surprise spike", 3, xyr]
      case 20:
        return ["buzzsaw", 3, xys]
      case 16:
        return ["growing block", 3, xys]
      case 21:
        return ["shuriken spawner", 3, xyr]
      case 23:
        return ["scythe", 3, xyr]
      case 22:
        return ["quadrant", 4, xysr]
      default:
        return [
          "?",
          Infinity,
          (a) => {
            return { a }
          },
        ]
    }
  })()
  var id = arr.splice(0, 1)[0]
  var data = arr.splice(0, count)
  blocks.push({
    vex2Id: id,
    id: name,
    w: SCALE,
    h: SCALE,
    r: 0,
    ...func(data),
    data,
  })
  if (blocks[blocks.length - 1].w !== undefined) {
    blocks[blocks.length - 1].w /= SCALE
    blocks[blocks.length - 1].h /= SCALE
  }
  blocks[blocks.length - 1].x *= 1
  blocks[blocks.length - 1].y *= 1
}
for (var b of blocks) {
  if (b.w === undefined) {
    // b.x -= 50
    b.y -= 13
  }
  switch (b.id) {
    case "microwave":
      b.options = { attachesToThings: false }
      break
    case "surprise spike":
    case "single spike":
      b.x += 5
      b.y += 16
      break
    case "shuriken spawner":
      b.y += 16
      b.w *= 1.75
      b.x += 7
      break
    case "10x spike":
    case "closing spikes":
      b.y += 16
      break
    case "buzzsaw":
    case "bouncing buzzsaw":
    case "growing buzzsaw":
      b.x -= b.w * 7 * 7
      b.y -= b.h * 7 * 7
      b.w *= 0.8
      b.h *= 0.8
      break
    case "scythe":
      b.w *= 1.75
      b.h *= 1.75
      break
    case "rotating buzzsaw":
    case "pole quadrant":
    case "laser":
    case "targeting laser":
      b.w *= 1.75
      b.h *= 1.75
      break
    case "checkpoint":
      b.w *= 1.75
      b.h *= 1.75
      break
    case "cannon":
      b.y += 15
      break
    case "gravity down lever":
    case "gravity up lever":
    case "speed up lever":
      b.y += 12
      b.x += 6
      break
    default:
      log(b.id)
  }
}
log(blocks)
fs.writeFileSync(
  "D:/godotgames/vex/maps/aaa/hub.sds",
  sds.saveData(blocks)
)
