
    void main() {
       	 vUv = uv;

        vec4 foo = vec4(position.x,position.y,position.z, 1.0 );
        vec4 mvPosition = modelViewMatrix * foo;

        mat4 RotationMatrix = mat4( cos(1.0), -sin(1.0), 0.0, 0.0,
                               sin(1.0),  cos(1.0), 0.0, 0.0,
                               0.0,           0.0, 1.0, 0.0,
                               0.0,           0.0, 0.0, 1.0 );



        gl_Position =  projectionMatrix  * mvPosition ;
    }