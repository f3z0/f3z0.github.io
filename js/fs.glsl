

vec4 mod289(vec4 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0; }

float mod289(float x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0; }

vec4 permute(vec4 x) {
     return mod289(((x*34.0)+1.0)*x);
}

float permute(float x) {
     return mod289(((x*34.0)+1.0)*x);
}

vec4 taylorInvSqrt(vec4 r)
{
  return 1.79284291400159 - 0.85373472095314 * r;
}

float taylorInvSqrt(float r)
{
  return 1.79284291400159 - 0.85373472095314 * r;
}

vec4 grad4(float j, vec4 ip)
  {
  const vec4 ones = vec4(1.0, 1.0, 1.0, -1.0);
  vec4 p,s;

  p.xyz = floor( fract (vec3(j) * ip.xyz) * 7.0) * ip.z - 1.0;
  p.w = 1.5 - dot(abs(p.xyz), ones.xyz);
  s = vec4(lessThan(p, vec4(0.0)));
  p.xyz = p.xyz + (s.xyz*2.0 - 1.0) * s.www; 

  return p;
  }
						
// (sqrt(5) - 1)/4 = F4, used once below
#define F4 0.309016994374947451

float snoise(vec4 v)
  {
  const vec4  C = vec4( 0.138196601125011,  // (5 - sqrt(5))/20  G4
                        0.276393202250021,  // 2 * G4
                        0.414589803375032,  // 3 * G4
                       -0.447213595499958); // -1 + 4 * G4

// First corner
  vec4 i  = floor(v + dot(v, vec4(F4)) );
  vec4 x0 = v -   i + dot(i, C.xxxx);

// Other corners

// Rank sorting originally contributed by Bill Licea-Kane, AMD (formerly ATI)
  vec4 i0;
  vec3 isX = step( x0.yzw, x0.xxx );
  vec3 isYZ = step( x0.zww, x0.yyz );
//  i0.x = dot( isX, vec3( 1.0 ) );
  i0.x = isX.x + isX.y + isX.z;
  i0.yzw = 1.0 - isX;
//  i0.y += dot( isYZ.xy, vec2( 1.0 ) );
  i0.y += isYZ.x + isYZ.y;
  i0.zw += 1.0 - isYZ.xy;
  i0.z += isYZ.z;
  i0.w += 1.0 - isYZ.z;

  // i0 now contains the unique values 0,1,2,3 in each channel
  vec4 i3 = clamp( i0, 0.0, 1.0 );
  vec4 i2 = clamp( i0-1.0, 0.0, 1.0 );
  vec4 i1 = clamp( i0-2.0, 0.0, 1.0 );

  //  x0 = x0 - 0.0 + 0.0 * C.xxxx
  //  x1 = x0 - i1  + 1.0 * C.xxxx
  //  x2 = x0 - i2  + 2.0 * C.xxxx
  //  x3 = x0 - i3  + 3.0 * C.xxxx
  //  x4 = x0 - 1.0 + 4.0 * C.xxxx
  vec4 x1 = x0 - i1 + C.xxxx;
  vec4 x2 = x0 - i2 + C.yyyy;
  vec4 x3 = x0 - i3 + C.zzzz;
  vec4 x4 = x0 + C.wwww;

// Permutations
  i = mod289(i); 
  float j0 = permute( permute( permute( permute(i.w) + i.z) + i.y) + i.x);
  vec4 j1 = permute( permute( permute( permute (
             i.w + vec4(i1.w, i2.w, i3.w, 1.0 ))
           + i.z + vec4(i1.z, i2.z, i3.z, 1.0 ))
           + i.y + vec4(i1.y, i2.y, i3.y, 1.0 ))
           + i.x + vec4(i1.x, i2.x, i3.x, 1.0 ));

// Gradients: 7x7x6 points over a cube, mapped onto a 4-cross polytope
// 7*7*6 = 294, which is close to the ring size 17*17 = 289.
  vec4 ip = vec4(1.0/294.0, 1.0/49.0, 1.0/7.0, 0.0) ;

  vec4 p0 = grad4(j0,   ip);
  vec4 p1 = grad4(j1.x, ip);
  vec4 p2 = grad4(j1.y, ip);
  vec4 p3 = grad4(j1.z, ip);
  vec4 p4 = grad4(j1.w, ip);

// Normalise gradients
  vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
  p0 *= norm.x;
  p1 *= norm.y;
  p2 *= norm.z;
  p3 *= norm.w;
  p4 *= taylorInvSqrt(dot(p4,p4));

// Mix contributions from the five corners
  vec3 m0 = max(0.6 - vec3(dot(x0,x0), dot(x1,x1), dot(x2,x2)), 0.0);
  vec2 m1 = max(0.6 - vec2(dot(x3,x3), dot(x4,x4)            ), 0.0);
  m0 = m0 * m0;
  m1 = m1 * m1;
  return 49.0 * ( dot(m0*m0, vec3( dot( p0, x0 ), dot( p1, x1 ), dot( p2, x2 )))
               + dot(m1*m1, vec2( dot( p3, x3 ), dot( p4, x4 ) ) ) ) ;

  }

	vec3 color_a = vec3(0.0,120.0/255.0,1.0);
	vec3 color_b = vec3(189.0/255.0,0.0,1.0);
	vec3 color_c = vec3(1.0,154.0,0.0);
	vec3 color_d = vec3(1.0/255.0,1.0,31.0);
	vec3 color_e = vec3(227.0/255.0,1.0,0.0);

// cartesian to polar coordinates
vec2 toPolar(vec2 uv) { return vec2(length(uv),atan(uv.y,uv.x)); }
// polar to cartesian coordinates
vec2 toCarte(vec2 z) { return z.x*vec2(cos(z.y),sin(z.y)); }
// 2d rotation matrix
mat2 uvRotate(float a) { return mat2(cos(a),sin(a),-sin(a),cos(a)); }
// A signed distance function for a rectangle
float sdfRect(vec2 uv, vec2 s) { vec2 auv = abs(uv); return max(auv.x-s.x,auv.y-s.y); }
// To fill an sdf with 0's or 1's
float fill(float d, float i) { return abs(smoothstep(.0,.02,d) - i); }

// palette from iq -> https://www.shadertoy.com/view/ll2GD3
vec3 pal(float d) { return .5 + .5 * cos(TAU*(d+vec3(.0,.10,.20))); }

// This makes a symmetric rotation around the origin.
// n is the number of slices, and everything is remmapped to the first one.
vec2 symrot(vec2 uv, float n) { 
    vec2 z = toPolar(uv); 
    return toCarte(vec2(z.x,mod(z.y,TAU / n) - TAU/(n*2.) ));
}

float map (vec3 p) {
    vec3 p1 = p;
    float geo = 1.;
    float cy = 0.2;
    const float repeat = 8.;
    p1.xy *= rot(length(p)*.5);
    
  
    float t = time*0.12;
  
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


void mainImage( out vec4 fragColor, in vec2 fragCoord )
  {


  vec2 fc = gl_FragCoord.xy;

    
    float kv = 1.0-(distance(gl_FragCoord.xy/iResolution,iPos/iResolution));

  	vec4 movie = texture2D(iChannel0,fc/iResolution);
    vec4 movieB = texture2D(iChannel1,fragCoord);

  	vec3 rgb = vec3(0.2126,0.7152,0.0722)*movie.xyz;
	float l = rgb.x+rgb.y+rgb.z;

	float radius = 5.0;

	float edgeOutBoundaryPct = 0.1+l*0.8;
	float edgeInBoundaryPct = edgeOutBoundaryPct/2.0;


	vec2 center_d = mod(fc, vec2(radius+radius)) - vec2(radius);
	float dist_squared = dot(center_d, center_d);
	float edgeInBoundary = (radius*radius*edgeInBoundaryPct*edgeInBoundaryPct);
	float edgeOutBoundary = (radius*radius*edgeOutBoundaryPct*edgeOutBoundaryPct);

	

//    vec4 n = vec4(snoise(seed),snoise(seed+17.0),snoise(seed+43.0),1.0);

	//n = vec4(1.0,1.0,1.0,1.0)-n*0.5;
     // fragColor = vec4(1.0,1.0,1.0,1.0)*snoise(vec3(n,n,n));

vec3 rgb_ = vec3(0.2126,0.7152,0.0722)*movieB.xyz;
  //=float l_ = rgb_.x+rgb_.y+rgb_.z;
float l_ = 1.0;
     //float l_ = sin(movie.x);
      fragColor = mix(vec4(l_,l_,l_,1.0), vec4(0.02,0.02,0.02, 1.0),
      	smoothstep(edgeInBoundary, edgeOutBoundary, dist_squared)); //smooth step provides anti-aliasing between edge boundaries

	//fragColor = vec4(l,l,l,1.0);
  
  }

  void main( void ){vec4 color = vec4(1.0,0.0,0.0,1.0);mainImage( color, vUv );gl_FragColor = color;}