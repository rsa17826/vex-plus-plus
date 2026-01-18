import fs from "fs"

import path from "path"
Object.assign(globalThis, console)

// Directory path
const directoryPath = "D:/godotgames/vex/scenes/blocks"

// Read the directory and process each file
fs.readdir(directoryPath, (err, files) => {
  if (err) {
    console.error("Error reading directory:", err)
    return
  }

  files.forEach((file) => {
    const filePath = path.join(directoryPath, file, "main.tscn")

    // Check if the file exists
    if (fs.existsSync(filePath)) {
      start(filePath)
    }
  })
})
function start(file) {
  var p = file
  var data = fs.readFileSync(p, "utf-8")
  if (
    data.includes('node name="attach detector" type="ShapeCast2D"')
  ) {
    return
  }
  log(file)

  // New section to replace
  const newSection = `[node name="attach detector" type="ShapeCast2D" parent="." node_paths=PackedStringArray("root")]
enabled = false
STARTSHAPE
target_position = Vector2(0, 0)
collision_mask = 32768
collide_with_areas = true
STARTSCRIPT
STARTROOT

`
  var addata = (data + "\n\n").match(
    /\[node name="attach detector".*?\n\n/s,
  )?.[0]
  var ad2data = (data + "\n\n").match(
    /^.*? parent="[^"]*attach detector"\][\s\S]*?\n\n/m,
  )?.[0]
  if (!addata || !ad2data) {
    error(
      "no data",
      p,
      "\n-----------------------------------",
      addata,
      "\n-----------------------------------",
      ad2data,
      "\n-----------------------------------",
      "\n-----------------------------------",
      "\n-----------------------------------",
    )
    return
  }
  const shapeRegex = /shape = SubResource\("[^"]+"\)$/m
  const shapeMatch = ad2data.match(shapeRegex)
  const extractedShape = shapeMatch ? shapeMatch[0] : "ERROR!!!!!" // Default if not found
  const rootRegex = /root = NodePath\("[^"]+"\)$/m
  const rootMatch = addata.match(rootRegex)
  const extractedroot = rootMatch ? rootMatch[0] : "ERROR!!!!!" // Default if not found
  const scriptRegex = /script = ExtResource\("[^"]+"\)$/m
  const scriptMatch = addata.match(scriptRegex)
  const extractedscript = scriptMatch ? scriptMatch[0] : "ERROR!!!!!" // Default if not found

  // Replace the section in the original content
  const updatedContent = data
    .replace(
      /\[node name="attach detector".*?\n\n/s,
      newSection
        .replace("STARTSHAPE", extractedShape)
        .replace("STARTROOT", extractedroot)
        .replace("STARTSCRIPT", extractedscript),
    )
    .replace(
      /\[gd_scene load_steps=(\d+)/,
      (_, num) => "[gd_scene load_steps=" + String(Number(num) - 1),
    )
    .replace(/^.*? parent="attach detector"\][\s\S]*?\n\n/m, "")

  if (updatedContent.includes("ERROR!!!!!")) {
    log("sdaasdakjaskj", p, addata)
  } else {
    fs.writeFileSync(p, updatedContent)
  }
}
