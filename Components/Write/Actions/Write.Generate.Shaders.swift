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
    
const vec3 GOLD = vec3(0.57, 0.57, 0.57);
const vec3 WHITE   = vec3(0.2, 0.2, 0.2);
const vec3 FADED_BLACK   = vec3(0.12, 0.12, 0.12);
const vec3 BLACK   = vec3(0.05, 0.05, 0.05);
    
float hash( float n ) {
    //return fract(sin(n)*43758.5453123);
    return fract(sin(n)*75728.5453123);
}
    

float noise( in vec2 x ) {
    vec2 p = floor(x);
    vec2 f = fract(x);
    f = f*f*(3.0-2.0*f);
    float n = p.x + p.y*57.0;
    return mix(mix( hash(n + 0.0), hash(n + 1.0), f.x), mix(hash(n + 57.0), hash(n + 58.0), f.x), f.y);
}
    
mat2 m = mat2( 0.6, 0.6, -0.6, 0.8);
float fbm(vec2 p){
    
    float f = 0.0;
    f += 0.5000 * noise(p); p *= m * 2.02;
    f += 0.2500 * noise(p); p *= m * 2.03;
    f += 0.1250 * noise(p); p *= m * 2.01;
    f += 0.0625 * noise(p); p *= m * 2.04;
    f /= 0.9375;
    return f;
}
    

void main(){
    
    // pixel ratio
    
    vec2 uv = gl_FragCoord.xy / u_resolution.xy ;
    vec2 p = - 1. + 2. * uv;
    p.x *= u_resolution.x / u_resolution.y;
    
    float r = sqrt(dot(p,p));
    float a = cos(p.y * p.x);
    
    float f = fbm( 5.0 * p);
    a += fbm(vec2(1.9 - p.x, 0.9 * (u_time * 0.024) + p.y));
    a += fbm(0.4 * p);
    r += fbm(2.9 * p);
    
    vec3 col = FADED_BLACK;
    
    float ff = 1.0 - smoothstep(-0.4, 1.1, noise(vec2(0.5 * a, 3.3 * a)) );
    col =  mix( col, GOLD, ff);
        
    ff = 1.0 - smoothstep(.0, 2.8, r );
    col +=  mix( col, BLACK,  ff);
    
    ff -= 1.0 - smoothstep(0.3, 0.5, fbm(vec2(1.0, 40.0 * a)) );
    col =  mix( col, WHITE,  ff);
        
    ff = 1.0 - smoothstep(2., 2.9, a * 1.5 );
    col =  mix( col, BLACK,  ff);
                                            
    gl_FragColor = vec4(col, 1.);
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
