shader_type spatial;
render_mode unshaded, cull_front;

uniform float outline_width = 0.02; // Уменьшили, чтобы подходило под мелкие предметы
uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 0.0, 1.0); // Сделаем желтым/золотым для интерактивности

void vertex() {
    VERTEX += NORMAL * outline_width;
}

void fragment() {
    ALBEDO = outline_color.rgb;
}