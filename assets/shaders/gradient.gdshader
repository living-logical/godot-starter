shader_type canvas_item;

uniform vec4 start_color: hint_color = vec4( 1.0 );
uniform vec4 end_color: hint_color = vec4( 0.0, 0.0, 0.0, 1.0 );
uniform float position: hint_range( -0.5, 0.5 ) = 0.0;
uniform float size: hint_range( 0.5, 2 ) = 0.5;
uniform float angle: hint_range( 0.0, 360.0 ) = 0.0;

void fragment() {
    float pivot = position + 0.5;
    vec2 uv = UV - pivot;
    float r_angle = radians( angle );
    float rotated = uv.x * cos( r_angle ) - uv.y * sin( r_angle );
    float pos = smoothstep( ( 1.0 - size ) + position, size + 0.0001 + position, rotated + pivot );

    COLOR = mix( start_color, end_color, pos );
}