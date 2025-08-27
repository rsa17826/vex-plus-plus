shader_type canvas_item;

uniform vec4 end:source_color;
uniform vec4 start:source_color;

void fragment() {
  if (end!=vec4(1,1,1,1)){
    // Check if the current color is not equal to the start color
        // Calculate the distance from the start color
        float distance = length(COLOR.rgb - start.rgb);
        
        // Interpolate between start and end based on the distance
        COLOR = mix(start, end, 1.0-distance);
    }
}