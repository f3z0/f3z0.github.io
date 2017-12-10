#ifdef GL_ES
precision mediump float;
#endif

#extension GL_OES_standard_derivatives : enable
#define M_PI 3.14159265358979323846
#define TAU 6.2831



// Leon 05 / 07 / 2017
// using lines of code of IQ, Mercury, LJ, Koltes, Duke

#define PI 3.14159

#define DITHER
#define STEPS 30.
#define BIAS 0.01
#define DIST_MIN 0.01

mat2 rot (float a) { float c=cos(a),s=sin(a);return mat2(c,-s,s,c); }
float sphere (vec3 p, float r) { return length(p)-r; }
float cyl (vec2 p, float r) { return length(p)-r; }
float torus( vec3 p, vec2 s ) {
  vec2 q = vec2(length(p.xz)-s.x,p.y);
  return length(q)-s.y;
}
float smin (float a, float b, float r) {
    float h = clamp(.5+.5*(b-a)/r,0.,1.);
    return mix(b,a,h)-r*h*(1.-h);
}
float rand(vec2 co) { return fract(sin(dot(co*0.123,vec2(12.9898,78.233))) * 43758.5453); }


float map (vec3 p) {
    vec3 p1 = p;
    float geo = 1.;
    float cy = 0.2;
    const float repeat = 8.;
    p1.xy *= rot(length(p)*.5);
		
	
    float t = iTime*0.12;
	
    for (float i = 0.; i < repeat; ++i) {
        p1.yz *= rot(0.3+t*0.5);
        p1.xy *= rot(0.2+t);
        p1.xz *= rot(.15+t*2.);
        
       	p1.xy *= rot(p.x*.5+t);
        
        // gyroscope
        geo = smin(geo, torus(p1,vec2(1.+i*.2,.02)), .5);
        
        // tentacles cylinders
        geo = smin(geo, cyl(p1.xz,.04), .5);
        
        // torus along the cylinders
        vec3 p2 = p1;
        p2.y = mod(p2.y,cy)-cy/2.;
        geo = smin(geo, torus(p2,vec2(.4,.01)), .2);
    }
    return geo;
}


vec4 renderShade(vec3 pos, vec3 ray) {
    float shade = 0.;
    #ifdef DITHER
    vec2 dpos = ( gl_FragCoord.xy / iResolution.xy );
    vec2 seed = dpos + fract(iTime);
    #endif 
    for (float i = 0.; i < STEPS; ++i) {
        float dist = map(pos);
        if (dist < BIAS) {
            shade += 1.;
        }
        #ifdef DITHER
        dist=abs(dist)*(.8+0.2*rand(seed*vec2(i)));
        #endif 
        dist = max(DIST_MIN,dist);
        pos += ray*dist;
    }
    return vec4(pos, shade);
}
void main( void ) {

	
	
	vec2 uv = (gl_FragCoord.xy-.5*iResolution.xy)/iResolution.y;
    vec3 eye = (vec3(uv,-3));
    vec3 ray = (normalize(vec3(uv,.5)));
    vec3 pos = eye;
    
	
	vec4 a = renderShade(pos, ray);
    float shade = a.w/(STEPS-1.);

   
	
	gl_FragColor = vec4(shade,shade/1.0,sqrt(shade),0.5);
}
