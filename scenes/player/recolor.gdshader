// No recolor

shader_type canvas_item;


uniform vec4 replace;

const float precision = 0.9;


vec4 swap_color(vec4 color){
  if (distance(color, vec4(0,0,0,1)) <= precision){
    return replace;
  }
  return color;
}


void fragment() {
  COLOR = swap_color(texture(TEXTURE, UV));
}

// Recolor

// shader_type canvas_item;


// uniform sampler2D palette;


// void fragment() {
//   vec4 color = texture(TEXTURE, UV);
//   vec4 result_color = texture(palette, color.rg);
//   result_color.a = color.a;
//   COLOR = result_color;
// }