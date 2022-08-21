#version 150

in vec3 Position;

uniform mat4 ModelViewMat;
uniform vec4 FogColor;
uniform mat4 ProjMat;

void main() {
	mat4 projMat = ProjMat;
    vec4 pos = projMat * vec4(Position, 1.0);
	pos.y = -pos.z;
	
	gl_Position = pos;
}
