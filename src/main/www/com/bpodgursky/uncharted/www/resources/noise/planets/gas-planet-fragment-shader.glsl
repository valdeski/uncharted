
varying vec3 vTexCoord3D;
uniform float time;

//  Noise fnunctions are taken from here:
//
// Description : Array and textureless GLSL 2D/3D/4D simplex
//               noise functions.
//      Author : Ian McEwan, Ashima Arts.
//  Maintainer : ijm
//     Lastmod : 20110822 (ijm)
//     License : Copyright (C) 2011 Ashima Arts. All rights reserved.
//               Distributed under the MIT License. See LICENSE file.
//               https://github.com/ashima/webgl-noise
//
vec4 permute( vec4 x ) {
  return mod( ( ( x * 34.0 ) + 1.0 ) * x, 289.0 );
}

vec4 taylorInvSqrt( vec4 r ) {
  return 1.79284291400159 - 0.85373472095314 * r;
}

float snoise( vec3 v ) {

  const vec2 C = vec2( 1.0 / 6.0, 1.0 / 3.0 );
  const vec4 D = vec4( 0.0, 0.5, 1.0, 2.0 );

  // First corner

  vec3 i  = floor( v + dot( v, C.yyy ) );
  vec3 x0 = v - i + dot( i, C.xxx );

  // Other corners

  vec3 g = step( x0.yzx, x0.xyz );
  vec3 l = 1.0 - g;
  vec3 i1 = min( g.xyz, l.zxy );
  vec3 i2 = max( g.xyz, l.zxy );

  //  x0 = x0 - 0. + 0.0 * C
  vec3 x1 = x0 - i1 + 1.0 * C.xxx;
  vec3 x2 = x0 - i2 + 2.0 * C.xxx;
  vec3 x3 = x0 - 1. + 3.0 * C.xxx;

  // Permutations

  i = mod( i, 289.0 );
  vec4 p = permute( permute( permute(
       i.z + vec4( 0.0, i1.z, i2.z, 1.0 ) )
       + i.y + vec4( 0.0, i1.y, i2.y, 1.0 ) )
       + i.x + vec4( 0.0, i1.x, i2.x, 1.0 ) );

  // Gradients
  // ( N*N points uniformly over a square, mapped onto an octahedron.)

  float n_ = 1.0 / 7.0; // N=7

  vec3 ns = n_ * D.wyz - D.xzx;

  vec4 j = p - 49.0 * floor( p * ns.z *ns.z );  //  mod(p,N*N)

  vec4 x_ = floor( j * ns.z );
  vec4 y_ = floor( j - 7.0 * x_ );    // mod(j,N)

  vec4 x = x_ *ns.x + ns.yyyy;
  vec4 y = y_ *ns.x + ns.yyyy;
  vec4 h = 1.0 - abs( x ) - abs( y );

  vec4 b0 = vec4( x.xy, y.xy );
  vec4 b1 = vec4( x.zw, y.zw );

  vec4 s0 = floor( b0 ) * 2.0 + 1.0;
  vec4 s1 = floor( b1 ) * 2.0 + 1.0;
  vec4 sh = -step( h, vec4( 0.0 ) );

  vec4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
  vec4 a1 = b1.xzyw + s1.xzyw * sh.zzww;

  vec3 p0 = vec3( a0.xy, h.x );
  vec3 p1 = vec3( a0.zw, h.y );
  vec3 p2 = vec3( a1.xy, h.z );
  vec3 p3 = vec3( a1.zw, h.w );

  // Normalise gradients

  vec4 norm = taylorInvSqrt( vec4( dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3) ) );
  p0 *= norm.x;
  p1 *= norm.y;
  p2 *= norm.z;
  p3 *= norm.w;

  // Mix final noise value

  vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3) ), 0.0 );
  m = m * m;
  return 42.0 * dot( m*m, vec4( dot(p0,x0), dot(p1,x1),
                dot(p2,x2), dot(p3,x3) ) );

}

const int octaves = 2;

 float noise(vec3 position, float frequency, float persistence) {
    float total = 0.0; // Total value so far
    float maxAmplitude = 0.0; // Accumulates highest theoretical amplitude
    float amplitude = 1.0;
    for (int i = 0; i < octaves; i++) {
        // Get the noise sample
        total += snoise(position * frequency) * amplitude;
        // Make the wavelength twice as small
        frequency *= 2.0;
        // Add to our maximum possible amplitude
        maxAmplitude += amplitude;
        // Reduce amplitude according to persistence for the next octave
        amplitude *= persistence;
    }
    // Scale the result by the maximum amplitude
    return total / maxAmplitude;
}

    void main( void ) {

      vec3 warp = vec3(vTexCoord3D);
      warp.x = warp.x * 50.0;

      float noiseBase = (noise(warp , .0006, 0.7)+1.0)/2.0;
      float noiseBase2 = (noise(warp , .06, 0.7)+1.0)/10.0;

       // Sunspots
      float frequency = 0.06;
      float brightNoise= snoise(vTexCoord3D * .02)*1.4- .9;

      float brightSpot = max(0.0, brightNoise);
      float total = noiseBase + brightSpot + noiseBase2;

      gl_FragColor = vec4(vec3(total, total*(204.0/255.0), total*(153.0/255.0)), 1.0);


			}

