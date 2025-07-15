// No recolor

shader_type canvas_item;


uniform vec4 replace_0;

const float precision = 0.9;


vec4 swap_color(vec4 color){
  vec4 original_colors[1] = vec4[1] (vec4(0,0,0,1));
  vec4 replace_colors[1] = vec4[1] (replace_0);
  for (int i = 0; i < 5; i ++) {
    if (distance(color, original_colors[i]) <= precision){
      return replace_colors[i];
    }
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