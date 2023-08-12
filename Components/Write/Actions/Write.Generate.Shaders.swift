//
//  Write.Generate.Shaders.swift
//  Loom
//
//  Created by PEXAVC on 7/22/23.
//

import Foundation

extension Write.Generate {
    static func shader(title: String,
                         author: String,
                         content: String,
                         urlString: String,
                         image_url: String) -> String {
        /*
         title
         author
         content
         url
         image_url
         
         */
        return """
<!DOCTYPE html>
<html>
<head>
  <title>\(title)</title>
  <meta charset="utf-8" />
<meta content='text/html; charset=utf-8' http-equiv='Content-Type'>
<meta http-equiv='X-UA-Compatible' content='IE=edge'>
<meta name='viewport' content="width=device-width,height=device-height, initial-scale=1, shrink-to-fit=yes">

<!--theme colors -->
<meta name="theme-color" content="" />
<meta name="apple-mobile-web-app-status-bar-style" content="">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">

<!--Basic meta info -->
<meta name="keywords" content="Loom, ipfs, lemmy, federated, content">
<meta name="author" content="\(author)" />
<meta name="description" content="">

<!--OpenGraph meta -->
<meta property="og:description" content="\(title)"/>
<meta property="og:title" content="\(title)" />
<meta property="og:image" content="\(image_url)"/>
<meta property="og:url" content="\(urlString)" />

<!--meta for twitter -->
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:creator" content="\(author)">
<meta name="twitter:title" content="\(title)">
<meta name="twitter:image" content="\(image_url)">
<meta name="twitter:site" content="\(urlString)">
<meta name="twitter:description" content="\(title)">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Courier+Prime:wght@400&display=swap');
        @import url('https://fonts.googleapis.com/css?family=Playfair+Display:400,400i,700,700i,900,900i');

        .container {
            display: flex;
            flex-wrap: wrap;
            justify-content: flex-start;
        }

        .containerData {
            display: flex;
            justify-content: center;
            width: 100%;
            height: 100vh;
            position: absolute;
            top: 0;
            left: 0;
            z-index: 0;
        }

        .codeContainer {
            display: flex;
            justify-content: center;
            width: 100%;
            height: 100vh;
            position: absolute;
            top: 0;
            left: 0;
            z-index: 2;
            overflow: hidden;
                align-items: center;
        }

        .containerBody {
            position: relative;
            text-align: center;
        }

        #canvas2 {
            position: absolute;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
        }

        .slideAnim {
            animation-name: slide;
            animation-duration: 2s;
            animation-fill-mode: forwards;

            /*New content */
            -webkit-animation-fill-mode: forwards;
        }

        @keyframes slide {
            from {
                opacity: 1.0;
            }

            to {
                opacity: 0.0;
            }

        }

        .titleC {
            font-family: 'Roboto', sans-serif;
            font-size: 36px;
            font-weight: 600;
            color: #FFF;
            padding: 0;
            margin: 0;
        }
        .headlineC {
            font-family: 'Roboto', sans-serif;
            font-size: 16px;
            font-weight: 300;
            color: #FFF;
            padding: 0;
            margin: 0;
        }

        .subheadlineC {
            font-family: 'Roboto', sans-serif;
            font-size: 16px;
            font-weight: 600;
            color: #FFF;
            padding: 0;
            margin: 0;
        }

        html,
        body {
            margin: 0;
            padding: 0;
            width: 100%;
            height: 100%;
            overflow: hidden;
        }

        a {
            text-decoration: none;
        }

        @media only screen and (max-width: 600px) {
          iframe {
            width: 90% !important;
            height: auto !important;
          }
        }
    </style>
    </head>

    <body>
        <script type="text/javascript" src="https://rawgit.com/patriciogonzalezvivo/glslCanvas/master/dist/GlslCanvas.js">
        
        </script>

        <div class="containerToTHEContainerheh">
            <div id="canvasContainer" class="containerData">
                <canvas id="canvas2" class="glslCanvas" data-fragment="precision highp float;
uniform vec2 u_resolution;
uniform float u_time;
uniform vec2 u_position;
                
const float cloudscale = 2.1;
const float speed = .025;
const float clouddark = 0.5;
const float cloudlight = 0.9;
const float cloudcover = 0.7;
const float cloudalpha = 100.0;
const float skytint = 0.5;
const vec3 skycolour1 = vec3(0.9, 0.1, 10.6);
const vec3 skycolour2 = vec3(0.4, 1.1, 01.0);

const mat2 m = mat2( 1.9,  1.2, -1.2,  0.9 );

vec2 hash( vec2 p ) {
    p = vec2(dot(p,vec2(127.1,311.7)), dot(p,vec2(269.5,183.3)));
    return -1.0 + 2.0*fract(sin(p)*43758.5453123);
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
    float total = 0.0, amplitude = 0.5;
    for (int i = 0; i < 7; i++) {
        total -= noise(n) * amplitude;
        n = m * n;
        amplitude *= 0.5;
    }
    return total;
}

// -----------------------------------------------

void main() {
    vec2 p = gl_FragCoord.xy / u_resolution.xy;
    vec2 uv = p*vec2(u_resolution.x/u_resolution.y,1.0);
    float time = u_time * speed;
    float q = fbm(uv * cloudscale * 0.5);
    
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
    float f = 0.0;
    uv = p*vec2(u_resolution.x/u_resolution.y,1.0);
    uv *= cloudscale;
    uv -= q - time;
    weight = 0.9;
    for (int i=0; i<8; i++){
        f += weight*noise( uv );
        uv = m*uv + time;
        weight *= 0.6;
    }
    
    f *= r + f;
    
    //noise colour
    float c = 0.0;
    time = u_time * speed * 2.0;
    uv = p*vec2(u_resolution.x/u_resolution.y,1.0);
    uv *= cloudscale*2.0;
    uv -= q - time;
    weight = 0.4;
    for (int i=0; i<7; i++){
        c += weight*noise( uv );
        uv = m*uv + time;
        weight *= .6;
    }
    
    //noise ridge colour
    float c1 = 0.0;
    time = u_time * speed * 3.0;
    uv = p*vec2(u_resolution.x/u_resolution.y,1.0);
    uv *= cloudscale*3.0;
    uv -= q - time;
    weight = 0.1;
    for (int i=0; i<7; i++){
        c1 += abs(weight*noise( uv ));
        uv = m*uv + time;
        weight *= 0.2;
    }
    
    c += c1;
    
    vec3 skycolour = mix(skycolour2, skycolour1, (p.x + p.y) * .7);
    vec3 cloudcolour = vec3(9.10, 0.0, 0.0) * clamp((clouddark + cloudlight*c), 0.0, 0.0);
   
    f = cloudcover + cloudalpha*f*r;
    
    vec3 result = mix(skycolour, clamp(skytint * skycolour + cloudcolour, 0.0, 0.0), clamp(f + c, 0.0, 1.0));
    
    gl_FragColor = vec4( result, 1.0 );
}" width="631px" height="631px"></canvas>
            </div>
            <div class="codeContainer">
                <div class="containerBody">
                    <iframe width="560" height="315" src="https://www.youtube.com/embed/\(content)?autoplay=1" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allow='autoplay' allowfullscreen></iframe>
                </div>
            </div>
        </div>
    </body>
</html>
"""
    }
}
