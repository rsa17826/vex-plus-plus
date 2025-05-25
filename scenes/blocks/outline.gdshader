shader_type canvas_item;

uniform vec4 color : source_color = vec4(69, 129, 255, 255);
uniform float width : hint_range(0, 200) = 200.0;
uniform int pattern : hint_range(0, 2) = 0; // diamond, circle, square
uniform bool inside = false;
uniform bool add_margins = true; // only useful when inside is false

uniform bool showTop = false;
uniform bool showBottom = false;
uniform bool showLeft = false;
uniform bool showRight = false;


void vertex() {
	if (add_margins) {
		VERTEX += (UV * 2.0 - 1.0) * width;
	}
}

bool hasContraryNeighbour(vec2 uv, vec2 texture_pixel_size, sampler2D texture) {
    float maxWidth = ceil(width);

    // Limit the search area if possible
    float searchRadius = min(maxWidth, 10.0); // Example: limit to a radius of 10

    for (float i = -searchRadius; i <= searchRadius; i++) {
        float x = abs(i) > width ? width * sign(i) : i;
        float offset;

        if (pattern == 0) {
            offset = width - abs(x);
        } else if (pattern == 1) {
            offset = floor(sqrt(pow(width + 0.5, 2) - x * x));
        } else { // pattern == 2
            offset = width;
        }

        for (float j = -ceil(offset); j <= ceil(offset); j++) {
            float y = abs(j) > offset ? offset * sign(j) : j;
            vec2 xy = uv + texture_pixel_size * vec2(x, y);

            // Check bounds directly instead of using clamp
            if (xy.x < 0.0 || xy.x > 1.0 || xy.y < 0.0 || xy.y > 1.0) {
                if (inside) return true; // Outside and inside
            } else {
                // Only check texture if within bounds
                float alpha = texture(texture, xy).a;
                if (alpha <= 0.0) {
                    if (inside) return true; // Transparent and inside
                } else {
                    if (!inside) return true; // Not transparent and outside
                }
            }
        }
    }

    return false;
}


void fragment() {
	vec2 uv = UV;

	if (add_margins) {
		vec2 texture_pixel_size = vec2(1.0) / (vec2(1.0) / TEXTURE_PIXEL_SIZE + vec2(width * 2.0));

		uv = (uv - texture_pixel_size * width) * TEXTURE_PIXEL_SIZE / texture_pixel_size;

		if (uv != clamp(uv, vec2(0.0), vec2(1.0))) {
			COLOR.a = 0.0;
		} else {
			COLOR = texture(TEXTURE, uv);
		}
	} else {
		COLOR = texture(TEXTURE, uv);
	}

	if ((COLOR.a > 0.0) == inside && hasContraryNeighbour(uv, TEXTURE_PIXEL_SIZE, TEXTURE)) {
    float offset = 0.0515;
    if (((uv.y<=(0.0+offset))&&showTop)||((uv.y>=(1.0-offset))&&showBottom||(uv.x<=(0.0+offset))&&showLeft)||((uv.x>=(1.0-offset))&&showRight)){
		COLOR.rgb = inside ? mix(COLOR.rgb, color.rgb, color.a) : color.rgb;
		COLOR.a += (1.0 - COLOR.a) * color.a;
    }
	}
}