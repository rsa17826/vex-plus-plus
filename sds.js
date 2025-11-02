// @noregex
// @name ts remover
// @regex (\)|\w)\??:.+?($|,|\)| \{)
// @replace $1$2

// loadlib("libloader").savelib("sds", {
//   saveData,
//   loadData,
//   setPP(val) {
//     prettyPrint = val
//   },
// })

function gettype(thing, match = undefined) {
  if (
    !match ||
    (Object.prototype.toString
      .call(match)
      .toLowerCase()
      .match(/^\[[a-z]+ (.+)\]$/)[1] == "string" &&
      !match.includes("|"))
  ) {
    var type = Object.prototype.toString
      .call(thing)
      .toLowerCase()
      .match(/^\[[a-z]+ (.+)\]$/)[1]
    if (type !== "function") if (type == match) return true
    if (match == "normalfunction") return type == "function"
    if (type == "htmldocument" && match == "document") return true
    if (match == "body" && type == "htmlbodyelement") return true
    if (match && new RegExp(`^html${match}element$`).test(type))
      return true
    if (/^html\w+element$/.test(type)) type = "element"
    if (type == "htmldocument") type = "element"
    if (type == "asyncfunction") type = "function"
    if (type == "generatorfunction") type = "function"
    if (type == "regexp") type = "regex"
    if (match == "regexp") match = "regex"
    if (match == "element" && type == "window") return true
    if (match == "element" && type == "shadowroot") return true
    if (match == "event" && /\w+event$/.test(type)) return true
    if (/^(html|svg).*element$/.test(type)) type = "element"
    if (type == "function") {
      type = /^\s*class\s/.test(
        Function.prototype.toString.call(thing)
      )
        ? "class"
        : "function"
    }
    if (match == "none")
      return type == "nan" || type == "undefined" || type == "null"
    try {
      if (type === "number" && isNaN(thing) && match == "nan")
        return true
    } catch (e) {
      error(thing)
    }
    return match ? match === type : type
  } else {
    if (match.includes("|")) match = match.split("|")
    match = [...new Set(match)]
    return !!match.indexOf((e) => gettype(thing, e))
  }
}

// Object.assign(globalThis, console)
// ;(async () => {
//   var b = await fs.readFile("D:\\godotgames\\vex\\maps\\tut\\hub.sds")
//   var data = b.toString()
//   // log(data)
//   var s = loadData(data, false)
//   log(s)
//   var d = saveData(s)
//   await fs.writeFile("D:\\godotgames\\vex\\maps\\tut\\hub2.sds", d)
//   while (1) {
//     debugger
//     await wait(1000)
//   }
//   // log(d, d == data)
//   log("")
// })()
var oldKeys = Object.keys.bind(Object)
Object.keys = function (obj) {
  if (gettype(obj, "objkeyobj")) {
    return obj.keys
  } else {
    return oldKeys.call(this, obj)
  }
}
async function wait(time) {
  return new Promise((r) => setTimeout(r, time))
}
function loadData(d, exact) {
  function randStr(count) {
    var str = ""
    for (let i = 0; i < count; ++i) {
      str += String.fromCharCode(Math.floor(97 + Math.random() * 25))
    }
    return str
  }
  class objKeyObj {
    keys
    values

    constructor(obj = undefined) {
      this.keys = []
      this.values = []

      if (obj) {
        log(obj)
        for (let k of Object.keys(obj)) {
          this.keys.push(k)
          this.values.push(obj[k])
        }
      }
    }
    set(k, v) {
      if (this.keys.includes(k)) {
        const index = this.keys.indexOf(k)
        this.values[index] = v
      } else {
        this.keys.push(k)
        this.values.push(v)
      }
    }
    get(k) {
      if (this.keys.includes(k)) {
        const index = this.keys.indexOf(k)
        return this.values[index]
      }
    }
    toString() {
      return `${this.keys.join(",")} = ${this.values.join(",")}`
    }

    get [Symbol.toStringTag]() {
      return "objkeyobj"
    }

    [Symbol.iterator]() {
      let index = 0
      const keys = this.keys
      const values = this.values

      return {
        next: () => {
          if (index < keys.length) {
            const result = {
              value: [keys[index], values[index]],
              done: false,
            }
            index++
            return result
          } else {
            return { done: true }
          }
        },
      }
    }
  }

  class int {
    #i
    constructor(i) {
      this.#i = Number(i)
    }
    toString() {
      return `${this.#i}`
    }
    toNumber() {
      return Math.floor(this.#i)
    }
    get [Symbol.toStringTag]() {
      return "int"
    }
  }
  class float {
    #i
    constructor(i) {
      this.#i = String(i)
      if (!/^-?\d+(?:\.\d+)?$/.test(this.#i)) {
        this.#i = String(NaN)
      }
    }
    toString() {
      return this.#i
      // if (this.#i % 1 === 0) {
      //   return `${this.#i.toFixed(1)}`
      // }
      // return `${this.#i.toFixed(14)}`.replace(/\.?0+$/, "")
    }
    toNumber() {
      return Number(this.#i)
    }
    get [Symbol.toStringTag]() {
      return "float"
    }
  }
  class Vector2 {
    x
    y
    constructor(x, y) {
      this.x = new float(x)
      this.y = new float(y)
    }
    toString() {
      return `Vector2(${this.x},${this.y})`
    }
    get [Symbol.toStringTag]() {
      return "vector2"
    }
  }
  class Vector2i {
    x
    y
    constructor(x, y) {
      this.x = new int(x)
      this.y = new int(y)
    }
    toString() {
      return `Vector2i(${this.x},${this.y})`
    }
    get [Symbol.toStringTag]() {
      return "vector2i"
    }
  }
  class Vector3 {
    x
    y
    z
    constructor(x, y, z) {
      this.x = new float(x)
      this.y = new float(y)
      this.z = new float(z)
    }
    toString() {
      return `Vector3(${this.x},${this.y},${this.z})`
    }
    get [Symbol.toStringTag]() {
      return "vector3"
    }
  }
  class Vector3i {
    x
    y
    z
    constructor(x, y, z) {
      this.x = new int(x)
      this.y = new int(y)
      this.z = new int(z)
    }
    toString() {
      return `Vector3i(${this.x},${this.y},${this.z})`
    }
    get [Symbol.toStringTag]() {
      return "vector3i"
    }
  }
  class Color {
    r
    g
    b
    a
    constructor(r, g, b, a) {
      this.r = new float(r)
      this.g = new float(g)
      this.b = new float(b)
      this.a = new float(a)
    }
    toString() {
      return `Color(${this.r}, ${this.g}, ${this.b}, ${this.a})`
    }
    get [Symbol.toStringTag]() {
      return "color"
    }
  }
  class StringName {
    s
    constructor(s) {
      this.s = s
    }
    toString() {
      return `${this.s}`
      // return `&"${this.s}"`
    }
    get [Symbol.toStringTag]() {
      return "string_name"
    }
  }
  var remainingData
  var UNSET = ":::" + randStr(12) + ":::"
  while (d.includes(UNSET)) {
    UNSET = ":::" + randStr(12) + ":::"
    log(UNSET)
  }
  remainingData = d?.trim() || ""
  if (!remainingData) {
    return UNSET
  }
  function __int(num) {
    return exact ? new int(num) : Number(num)
  }
  function __float(num) {
    return exact ? new float(num) : Number(num)
  }

  function getDataFind() {
    var end = remainingData.indexOf(")")
    var part = remainingData.substr(1, end - 1)
    remainingData = remainingData.substr(end + 1)
    return part
  }

  var _stack = []

  while (1) {
    if (!remainingData) {
      // log.warn(_stack, stack, 4)
      return _stack[_stack.length - 1]
    }

    if (remainingData[0] == "]" || remainingData[0] == "}") {
      remainingData = remainingData.substr(1)
      remainingData = remainingData.trim()
      // log("DADSADSA", remainingData)
      if (!remainingData) {
        // log.warn(_stack, stack, 1)
        // _stack.push(_stack[_stack.length - 1])
        while (_stack.length >= 2) {
          var thing1 = _stack.pop()
          var lastItem = _stack[_stack.length - 1]
          if (lastItem == null) {
            _stack[_stack.length - 1] = thing1
          } else if (gettype(lastItem, "objkeyobj")) {
            for (var k of Object.keys(lastItem)) {
              if (lastItem.get(k) == UNSET) {
                lastItem.set(k, thing1)
                break
              } else if (gettype(lastItem, "array")) {
                lastItem.push(thing1)
                // log(_stack)
              }
            }
          } else if (gettype(lastItem, "object")) {
            for (var k of Object.keys(lastItem)) {
              if (lastItem[k] == UNSET) {
                lastItem[k] = thing1
                break
              } else if (gettype(lastItem, "array")) {
                lastItem.push(thing1)
                // log(_stack)
              }
            }
          }
        }
        return _stack[0]
      }
      var dataToInsert = _stack.pop()
      var thingToPutDataIn = _stack.pop()
      // log.warn(thingToPutDataIn, dataToInsert)
      switch (gettype(thingToPutDataIn)) {
        case "object":
          for (var k of Object.keys(thingToPutDataIn)) {
            if (thingToPutDataIn[k] == UNSET) {
              thingToPutDataIn[k] = dataToInsert
              break
            }
          }
          break
        case "objkeyobj":
          for (var k of Object.keys(thingToPutDataIn)) {
            if (thingToPutDataIn.get(k) == UNSET) {
              thingToPutDataIn.set(k, dataToInsert)
              break
            }
          }
          break
        case "array":
          thingToPutDataIn.push(dataToInsert)
          break
      }
      _stack.push(thingToPutDataIn)
      // remainingData = remainingData
      // stack.push([remainingData, _stack])
      continue
    }
    remainingData = remainingData.trim()
    if (!remainingData) {
      error(remainingData, "current")
      // debugger
      return UNSET
    }
    var type
    if (remainingData[0] == "{") {
      type = "{"
    } else if (remainingData[0] == "[") {
      type = "["
    } else {
      type = remainingData.substr(0, remainingData.indexOf("("))
    }
    remainingData = remainingData.substr(type.length)
    // if (type == UNSET){
    //   log.warn(remainingData)
    remainingData = remainingData.trim()
    // log("asdjhdash", type, remainingData)
    // log(remainingData, type)
    var thisdata
    switch (type) {
      case "{":
        thisdata = UNSET
        // remainingData = remainingData.substr(1)
        _stack.push(exact ? new objKeyObj() : {})
        break
      case "INT":
        thisdata = getDataFind()
        thisdata = __int(thisdata)
        break
      case "FLOAT":
        thisdata = getDataFind()
        thisdata = __float(thisdata)
        break
      case "VEC2I":
        thisdata = getDataFind().split(",")
        thisdata = new Vector2i(
          __int(thisdata[0]),
          __int(thisdata[1])
        )
        break
      case "VEC2":
        thisdata = getDataFind().split(",")
        thisdata = new Vector2(
          __float(thisdata[0]),
          __float(thisdata[1])
        )
        break
      case "VEC3I":
        thisdata = getDataFind().split(",")
        thisdata = new Vector3i(
          __int(thisdata[0]),
          __int(thisdata[1]),
          __int(thisdata[2])
        )
        break
      case "VEC3":
        thisdata = getDataFind().split(",")
        thisdata = new Vector3(
          __float(thisdata[0]),
          __float(thisdata[1]),
          __float(thisdata[2])
        )
        break
      case "COLOR":
        thisdata = getDataFind().split(",")
        thisdata = new Color(
          __float(thisdata[0]),
          __float(thisdata[1]),
          __float(thisdata[2]),
          __float(thisdata[3])
        )
        break
      // case "RECT2":
      //       //   thisdata = (getDataFind().split(","))
      //       //   thisdata = Rect2(__float(thisdata[0]), __float(thisdata[1]), __float(thisdata[2]), __float(thisdata[3]))
      //       // break
      // case "RECT2I":
      //       //   thisdata = (getDataFind().split(","))
      //       //   thisdata = Rect2i(__int(thisdata[0]), __int(thisdata[1]), __int(thisdata[2]), __int(thisdata[3]))
      //       // break
      // case "VEC4":
      //       //   thisdata = (getDataFind().split(","))
      //       //   thisdata = Vector4(__float(thisdata[0]), __float(thisdata[1]), __float(thisdata[2]), __float(thisdata[3]))
      //       // break
      // case "VEC4I":
      //       //   thisdata = (getDataFind().split(","))
      //       //   thisdata = Vector4i(__int(thisdata[0]), __int(thisdata[1]), __int(thisdata[2]), __int(thisdata[3]))
      //       // break
      // case // "InputEventKey":
      //       //   thisdata = getDataReg(r"^\((" +
      //       //   NUMREG + SEPREG +
      //       //   r"(?:true|false)" + SEPREG +
      //       //   r"(?:true|false)" + SEPREG +
      //       //   r"(?:true|false)" + SEPREG +
      //       //   r"(?:true|false)" + r")\)", 1).split(",")
      //       //   var evt = InputEventKey.new()
      //       //   evt.set_keycode(int(thisdata[0]))
      //       //   evt.ctrl_pressed = thisdata[1] == "true"
      //       //   evt.alt_pressed = thisdata[2] == "true"
      //       //   evt.shift_pressed = thisdata[3] == "true"
      //       //   evt.meta_pressed = thisdata[4] == "true"
      //       //   thisdata = evt
      //       // break
      // case // "InputEventMouseButton":
      //       //   thisdata = getDataReg(r"^\((" +
      //       //   NUMREG + SEPREG +
      //       //   r"(?:true|false)" + SEPREG +
      //       //   r"(?:true|false)" + SEPREG +
      //       //   r"(?:true|false)" + SEPREG +
      //       //   r"(?:true|false)" + r")\)", 1).split(",")
      //       //   var evt = InputEventMouseButton.new()
      //       //   evt.set_button_index(int(thisdata[0]))
      //       //   evt.ctrl_pressed = thisdata[1] == "true"
      //       //   evt.alt_pressed = thisdata[2] == "true"
      //       //   evt.shift_pressed = thisdata[3] == "true"
      //       //   evt.meta_pressed = thisdata[4] == "true"
      //       //   thisdata = evt
      //       break
      case "NULL":
        getDataFind()
        thisdata = null
        break
      case "BOOL":
        thisdata = getDataFind()
        // thisdata = getDataReg(r"\((true|false)\)", 1)
        thisdata = thisdata == "true"
        break
      case "STR":
        // if ('loadOnlineLevelListOnSceneLoad' ! in remainingData && '\\' in remainingData){
        //   log(remainingData)
        //   debugger
        thisdata = remainingData
          .replace("\\\\", "ESCAPED" + UNSET)
          .replace("\\)", "PERIN" + UNSET) // replace the escaped escapes, then replace the escaped )s with data ! used in the saved data to let the regex detect the real ending )
        thisdata = thisdata.substr(1, thisdata.indexOf(")") - 1) // get the data from the start ( to the first real ), ! escaped ), that were hid just above
        thisdata = thisdata
          .replace("ESCAPED" + UNSET, "\\\\")
          .replace("PERIN" + UNSET, ")") // restore the hidden \ && )s
        remainingData = remainingData.substr(
          thisdata.replace("\\", "\\").replace(")", "\\)").length + 2 // re expand the replacements to make same length as the escaped chars would be
        )
        thisdata = thisdata.replace("\\\\", "\\")
        break
      case "STRNAME":
        thisdata = remainingData
          .replace("\\\\", "ESCAPED" + UNSET)
          .replace("\\)", "PERIN" + UNSET) // replace the escaped escapes, then replace the escaped )s with data ! used in the saved data to let the regex detect the real ending )
        thisdata = thisdata.substr(1, thisdata.indexOf(")") - 1) // get the data from the start ( to the first real ), ! escaped ), that were hid just above
        thisdata = thisdata
          .replace("ESCAPED" + UNSET, "\\\\")
          .replace("PERIN" + UNSET, ")") // restore the hidden \ && )s
        remainingData = remainingData.substr(
          thisdata.replace("\\", "\\\\").replace(")", "\\)").length + // re expand the replacements to make same length as the escaped chars would be
            2
        )
        thisdata = exact ? new StringName(thisdata) : thisdata
        break
      case "[":
        thisdata = UNSET
        // remainingData = remainingData.substr(1)
        _stack.push([])
        break
      default:
        error("bad type", type.length, type, remainingData, 12312)
        // debugger
        if (type == UNSET) {
          return UNSET
        }
        return
    }
    remainingData = remainingData.trim()
    if (thisdata !== UNSET) {
      if (_stack.length) {
        var lastItem = _stack[_stack.length - 1]
        if (lastItem == null) {
          _stack[_stack.length - 1] = thisdata
        } else {
          if (gettype(lastItem, "object")) {
            var innerDataFound = false
            for (let k of Object.keys(lastItem)) {
              if (lastItem[k] == UNSET) {
                innerDataFound = true
                lastItem[k] = thisdata
                break
              }
            }
            if (!innerDataFound) {
              lastItem[thisdata] = UNSET
            }
          } else if (gettype(lastItem, "objkeyobj")) {
            var innerDataFound = false
            for (let k of Object.keys(lastItem)) {
              if (lastItem.get(k) == UNSET) {
                innerDataFound = true
                lastItem.set(k, thisdata)
                break
              }
            }
            if (!innerDataFound) {
              lastItem.set(thisdata, UNSET)
            }
          } else if (gettype(lastItem, "array")) {
            lastItem.push(thisdata)
          }
        }
      } else {
        error("adssadhasdkhsahdhkahdasjk")
        // stack.push([remainingData, _stack])
        continue
      }
      // // log.warn("no obj")
      // log.warn(out, stack, _stack, thisdata, 2)
      // return thisdata
      // log(thisdata, out, remainingData, "_stack, String(_stack))
      // if (remainingData.length){
      // Push the current state back onto the stack for the next iteration
      // stack.push([remainingData, _stack])
      continue // ?
    }
  }
  error("asdasd")
  return _stack[_stack.length - 1]
}

var prettyPrint = true

function saveData(val, _level = 0) {
  // print("saveData", val)
  function getIndent(level) {
    if (!prettyPrint) {
      return ""
    }

    var indent = "\n"
    for (var i = 0; i < level; i++) {
      indent += "  "
    }
    return indent
  }
  if (gettype(val, "InputEventKey")) {
    return (
      "InputEventKey(" +
      String(val.physical_keycode) +
      "," +
      String(val.ctrl_pressed) +
      "," +
      String(val.alt_pressed) +
      "," +
      String(val.shift_pressed) +
      "," +
      String(val.meta_pressed) +
      ")"
    )
  } else if (gettype(val, "InputEventMouseButton")) {
    return (
      "InputEventMouseButton(" +
      String(val.button_index) +
      "," +
      String(val.ctrl_pressed) +
      "," +
      String(val.alt_pressed) +
      "," +
      String(val.shift_pressed) +
      "," +
      String(val.meta_pressed) +
      ")"
    )
  } else {
    switch (gettype(val)) {
      case "color":
        return (
          "COLOR(" +
          val.r +
          "," +
          val.g +
          "," +
          val.b +
          "," +
          val.a +
          ")"
        )
      case "rect2":
        return (
          "RECT2(" +
          String(val.position[0]) +
          "," +
          String(val.position[1]) +
          "," +
          String(val.size[0]) +
          "," +
          String(val.size[1]) +
          ")"
        )
      case "rect2i":
        return (
          "RECT2I(" +
          String(val.position[0]) +
          "," +
          String(val.position[1]) +
          "," +
          String(val.size[0]) +
          "," +
          String(val.size[1]) +
          ")"
        )
      case "string_name":
        return (
          "STRNAME(" +
          String(val).replace("\\", "\\\\").replace(")", "\\)") +
          ")"
        )
      case "vector4":
        return "VEC4" + String(val).replace(" ", "")
      case "vector4i":
        return "VEC4I" + String(val).replace(" ", "")
      case "int":
        return "INT(" + String(val) + ")"
      case "number":
      case "float":
        return "FLOAT(" + String(val) + ")"
      case "vector2":
        return "VEC2(" + String(val.x) + "," + String(val.y) + ")"
      case "vector2i":
        return "VEC2I(" + String(val.x) + "," + String(val.y) + ")"
      case "vector3":
        return (
          "VEC3(" +
          String(val.x) +
          "," +
          String(val.y) +
          "," +
          String(val.z) +
          ")"
        )
      case "vector3i":
        return (
          "VEC3I(" +
          String(val.x) +
          "," +
          String(val.y) +
          "," +
          String(val.z) +
          ")"
        )
      case "string":
        return (
          "STR(" +
          String(val).replace("\\", "\\\\").replace(")", "\\)") +
          ")"
        )
      case "boolean":
        return "BOOL(" + String(val) + ")"
      case "null":
        return "NULL()"
      case "nil":
        return "NULL()"
      case "objkeyobj":
        var data = ""
        _level += 1
        var hasKey = false
        for (let inner of Object.keys(val)) {
          hasKey = true
          data +=
            getIndent(_level) +
            saveData(inner, _level) +
            saveData(val.get(inner), _level)
        }
        _level -= 1
        return hasKey
          ? "{" + data + getIndent(_level) + "}"
          : "{" + data + "}"
      case "object":
        var data = ""
        _level += 1
        var hasKey = false
        for (let inner of Object.keys(val)) {
          hasKey = true
          data +=
            getIndent(_level) +
            saveData(inner, _level) +
            saveData(val[inner], _level)
        }
        _level -= 1
        return hasKey
          ? "{" + data + getIndent(_level) + "}"
          : "{" + data + "}"
      case "array":
        var data = ""
        _level += 1
        var hasKey = false
        for (let inner of val) {
          hasKey = true
          data += getIndent(_level) + saveData(inner, _level)
        }
        _level -= 1
        return hasKey
          ? "[" + data + getIndent(_level) + "]"
          : "[" + data + "]"
      default:
        error(val, gettype(val))
        throw new Error(val)
      // debugger
    }
  }
  error(val, gettype(val))
  // debugger
  return String(val)
}
export default { loadData, saveData }
