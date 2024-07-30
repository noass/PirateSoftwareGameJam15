shader_type canvas_item;

#define iTime TIME
#define iResolution 1.0/SCREEN_PIXEL_SIZE
#define fragColor COLOR
#define fragCoord FRAGCOORD

uniform float uOpacity; // Uniform variable for opacity control

vec3 firePalette(float i){

    float T = 1400. + 1300.*i;
    vec3 L = vec3(7.4, 5.6, 4.4);
    L = pow(L,vec3(5)) * (exp(1.43876719683e5/(T*L)) - 1.);
    return 1. - exp(-5e8/L);
}

vec3 hash33(vec3 p){ 
    
    float n = sin(dot(p, vec3(7, 157, 113)));    
    return fract(vec3(2097152, 262144, 32768)*n); 
}

float voronoi(vec3 p){

    vec3 b, r, g = floor(p);
    p = fract(p);

    float d = 1.; 
     
    for(int j = -1; j <= 1; j++) {
        for(int i = -1; i <= 1; i++) {
            
            b = vec3(float(i), float(j), -1);
            r = b - p + hash33(g+b);
            d = min(d, dot(r,r));
            
            b.z = 0.0;
            r = b - p + hash33(g+b);
            d = min(d, dot(r,r));
            
            b.z = 1.;
            r = b - p + hash33(g+b);
            d = min(d, dot(r,r));
                
        }
    }
    
    return d;
}

float noiseLayers(in vec3 p) {
    vec3 t = vec3(0., 0., p.z + iTime*1.5);

    const int iter = 5;
    float tot = 0., sum = 0., amp = 1.;

    for (int i = 0; i < iter; i++) {
        tot += voronoi(p + t) * amp;
        p *= 2.;
        t *= 1.5;
        sum += amp;
        amp *= .5;
    }
    
    return tot/sum;
}

void fragment()
{
    vec2 uv = (UV - 0.5) * vec2( SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x, 1.0);
    
    uv += vec2(sin(iTime*.5)*.25, cos(iTime*.5)*.125);
    
    vec3 rd = normalize(vec3(uv.x, uv.y, 3.1415926535898/8.));

    float cs = cos(iTime*.25), si = sin(iTime*.25);
    rd.xy = rd.xy*mat2(vec2(cs, -si), vec2(si, cs)); 
    
    float c = noiseLayers(rd*2.);
    
    c = max(c + dot(hash33(rd)*2. - 1., vec3(.015)), 0.);

    c *= sqrt(c)*1.5;
    vec3 col = vec3(1.0);
    col *= c;
    
    float alpha = uOpacity * c; // Use the uniform variable to control opacity

    fragColor = vec4(sqrt(clamp(col, 0., 1.)), alpha);
}
