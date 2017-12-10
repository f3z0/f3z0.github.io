// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Created by S.Guillitte

const mat2 m2 = mat2(.8,.6,-.6,.8);
const float cloudscale = 1.1;
const float speed = 0.005;
const float clouddark = 0.05;
const float cloudlight = 0.2;
const float cloudcover = 0.01;
const float cloudalpha = 1.5;
const float skytint =1.11;
const vec3 skycolour1 = vec3(12.0/255.0, 44.0/255.0, 85.0/255.0);
const vec3 skycolour2 = vec3(29.0/255.0, 68.0/255.0, 122.0/255.0);

const mat2 m = mat2( 1.6,  1.2, -1.2,  1.6 );


vec2 hash( vec2 p ) {
	p = vec2(dot(p,vec2(127.1,311.7)), dot(p,vec2(269.5,183.3)));
	return -1.0 + 2.0*fract(sin(p)*43758.5453123);
}


float stars(in vec2 p){
    vec2 z = p;
    p=floor(p*10.)/10.+0.1;
	float r = 80.*dot(z-p,z-p);
    z=p;
	for( int i=0; i< 2; i++ ) 
	{		
       z=m2*z*1.1+1.3;
       z+=15.*sin(z+3.*sin(p.yx));        
	}        	
	return clamp(2.5-length(z),0.,1.)*exp(-r);
}

float noise( in vec2 p ) {
    const float K1 = 0.366025404; // (sqrt(3)-1)/2;
    const float K2 = 0.211324865; // (3-sqrt(3))/6;
	vec2 i = floor(p + (p.x+p.y)*K1);	
    vec2 a = p - i + (i.x+i.y)*K2;
    vec2 o = (a.x>a.y) ? vec2(1.0,0.0) : vec2(0.0,1.0); //vec2 of = 0.5 + 0.5*vec2(sign(a.x-a.y), sign(a.y-a.x));
    vec2 b = a - o + K2;
	vec2 c = a - 1.0 + 2.0*K2;
    vec3 h = max(0.5-vec3(dot(a,a), dot(b,b), dot(c,c) ), 0.0 );
	vec3 n = h*h*h*h*vec3( dot(a,hash(i+0.0)), dot(b,hash(i+o)), dot(c,hash(i+1.0)));
    return dot(n, vec3(70.0));	
}

float fbm(vec2 n) {
	float total = 0.0, amplitude = 0.1;
	for (int i = 0; i < 7; i++) {
		total += noise(n) * amplitude;
		n = m * n;
		amplitude *= 0.4;
	}
	return total;
}

vec2 rotate(vec2 v, float a) {
	float s = sin(a);
	float c = cos(a);
	mat2 m = mat2(c, -s, s, c);
	return m * v;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{

		vec2 p = 15.*(-iResolution.xy+2.0*fragCoord.xy)/iResolution.y;

		float f = stars(vec2(1.0,2.0)*rotate(p, mod(iTime*0.01,M_PI*2.0)));
	 p = fragCoord.xy / iResolution.xy;

	vec2 uv = p*vec2(iResolution.x/iResolution.y,1.0);  

float time = iTime * speed;
	

    float q = fbm(uv * cloudscale * 0.5);
    
       vec4 tex = texture2D(iChannel2, cos((1000000.0+iTime)/100.0)*sin((1000000.0+iTime)/100.0)+fragCoord/iResolution.xy);

    f=clamp(tex.x,0.5,1.0)*f;

    vec3 skycolour = mix(skycolour2, skycolour1, p.y);


    vec3 col = skycolour +vec3(f*f*f,f*f*.8,f*.8);
    f= 0.0;
    


    //ridged noise shape
	float r = 0.0;

	uv *= cloudscale;

    uv -= q - time;
    float weight = 0.8;
    for (int i=0; i<8; i++){
		r += abs(weight*noise( uv ));
        uv = m*uv + time;
		weight *= 0.7;
    }
    
    //noise shape
   f = 0.0;

    uv = p*vec2(iResolution.x/iResolution.y,1.0);
	uv *= cloudscale;
    uv -= q - time;
    weight = 0.7;
    for (int i=0; i<8; i++){
		f += weight*noise( uv );
        uv = m*uv + time;
		weight *= 0.6;
    }
    
    f *= r + f;
    
    //noise colour
    float c = 0.0;
    time = iTime * speed * 2.0;
    uv = p*vec2(iResolution.x/iResolution.y,1.0);
	uv *= cloudscale*2.0;
    uv -= q - time;
    weight = 0.4;
    for (int i=0; i<7; i++){
		c += weight*noise( uv );
        uv = m*uv + time;
		weight *= 0.6;
    }
    
    //noise ridge colour
    float c1 = 0.0;
    time = iTime * speed * 3.0;
    uv = p*vec2(iResolution.x/iResolution.y,1.0);
	uv *= cloudscale*3.0;
    uv -= q - time;
    weight = 0.4;
    for (int i=0; i<7; i++){
		c1 += abs(weight*noise( uv ));
        uv = m*uv + time;
		weight *= 0.6;
    }
	
    c += c1;
    
    vec3 cloudcolour = vec3(1.1, 1.1, 0.9) * clamp((clouddark + cloudlight*c), 0.0, 1.0);

    f =   cloudcover + cloudalpha*f*r;

	if(f>.5)col =skycolour;
    else col = mix(col,skycolour,skycolour*0.1);


    
    vec3 result = mix( col, clamp(skytint * skycolour + cloudcolour*(1.0-clamp(cos(fragCoord.y/(iResolution.y)),0.0,1.0)), 0.0, 1.0), clamp(f + c, 0.0, 1.0));
    
    
	fragColor = vec4( result, 1.0 );/*
    
   //f = dot(f,tex);
    
        	p+=.8*iTime;	

	vec3 col = vec3(f*f*f,f*f*.8,f*.8);
    f= clamp(fbm(p*.1),0.,1.);
    if(f>.1)col =vec3(f*f*f,f*f,f);
    else col = mix(col,vec3(f*f*f,f*f,f),5.*f);

	fragColor = vec4(col,1.0);*/
}
  void main( void ){vec4 color = vec4(1.0,0.0,0.0,1.0);mainImage( color, gl_FragCoord.xy );gl_FragColor = color;}