shader_type canvas_item;

uniform vec4 color : source_color = vec4(69, 129, 255, 255);
uniform float width : hint_range(0, 200) = 20.0;
uniform bool add_margins = true; // only useful when inside is false
uniform float xSize = 0.0215;
uniform float ySize = 0.0215;

uniform bool showTop = false;
uniform bool showBottom = false;
uniform bool showLeft = false;
uniform bool showRight = false;


void vertex() {
  if (add_margins) {
    VERTEX += (UV * 2.0 - 1.0) * width;
  }
}

void fragment() {
  if (((UV.y<=(0.0+ySize))&&showTop)||((UV.y>=(1.0-ySize))&&showBottom||(UV.x<=(0.0+xSize))&&showLeft)||((UV.x>=(1.0-xSize))&&showRight)){
    COLOR.rgba = color.rgba;
    //COLOR.a=1.0;
    //COLOR.a += (1.0 - COLOR.a) * color.a;
  }
}