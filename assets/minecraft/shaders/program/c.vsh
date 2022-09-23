#version 150

out vec2 texCoord;

void main(){
    switch(gl_VertexID % 4) {
        case 0:
            gl_Position = vec4(-1.0, -1.0, 0.2, 1.0);
            texCoord = vec2(0.0, 0.0);
            return;
        case 1:
            gl_Position = vec4( 1.0, -1.0, 0.2, 1.0);
            texCoord = vec2(1.0, 0.0);
            return;
        case 2:
            gl_Position = vec4( 1.0,  1.0, 0.2, 1.0);
            texCoord = vec2(1.0, 1.0);
            return;
        case 3:
            gl_Position = vec4(-1.0,  1.0, 0.2, 1.0);
            texCoord = vec2(0.0, 1.0);
            return;
    }
}
