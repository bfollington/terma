/*================================
=          Liquid Tech           =
=         Author: Jaenam         =
================================*/
// Date:    2025-10-19
// License: Creative Commons (CC BY-NC-SA 4.0)

void mainImage( out vec4 O, vec2 I )
{
    float i,d,s;
    vec3 p, r = iResolution;
    mat2 R = mat2(cos(iTime/2.+vec4(0,33,11,0)));

    for(O*=i; i++<1e2; O+=max(1.3*sin(vec4(3,2,1,1)+i*.3)/s,-length(p*p)))

        p = vec3((I+I - r.xy)/r.y*d*R, d-8.), p.xz*=R,
        d+=s=.012+.08*abs(max(sin(dot(p.yzx,p)/.7),length(p)-4.)-i/1e2);

    O=tanh(O*O/8e5);

}

/* Twigl version

https://x.com/Jaenam97/status/1979924313215033855

*/
