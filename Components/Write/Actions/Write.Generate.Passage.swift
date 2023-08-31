//
//  Write.Generate.Passage.swift
//  Loom
//
//  Created by PEXAVC on 7/22/23.
//

import Foundation
import FederationKit

extension Write.Generate {
    static func htmlReader(title: String, author: String, content: [String], urlString: String, image_url: String, songId: String? = nil) -> String {
        return Write.Generate.htmlText1(title: title, author: author, content: content, urlString: urlString, image_url: image_url) + htmlText2(songId)
    }
    
    static var quote: String { """
    <div class='epigraph'><p>Loom is an app client for Lemmy. Meant for writers to share thoughts on a many-to-many social network. While persisting their works on IPFS.</p><p class='attribution'><a href="https://twitter.com/pexavc">@PEXAVC</a></p></div>
    """
    }
    
    static func createQuote(_ value: String? = nil) -> String {
        let person = FederationKit.user()?.resource.user.person
        let user = person?.name ?? ""
        let url = person?.actor_id ?? ""
        
        var quoteBody: String = ""
        if let value {
            quoteBody = "<p>\(value)</p>"
        }
        
        return """
        <div class='epigraph'>\(quoteBody)<p class='attribution'><a href="\(url)">@\(user)</a></p></div>
        """
    }
    static func htmlText1(title: String,
                          author: String,
                          content: [String],
                          urlString: String,
                          image_url: String,
                          quoteValue: String? = nil) -> String { """
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
    
    @font-face {
            font-family: 'HVD Bodedo Medium';
            src: url('HVD_Bodedo.eot');
            src: local('HVD Bodedo Medium'), local('HVDBodedo-Medium'), url('HVD_Bodedo.ttf') format('truetype');
    }
    
    @font-face {
      font-family: 'Thomas Paine';
      src: local('Thomas Paine Regular'), local('ThomasPaine-Regular'), url('ThomasPaine-Regular.ttf') format('truetype');
    }
    
    /* rhythm magic */
    body,div,dl,dt,dd,ul,ol,li,h1,h2,h3,h4,h5,h6,pre,form,fieldset,p,blockquote,th,td {
            margin:0; padding:0;
            text-rendering: optimizeLegibility;
    }
    body { font-size: 87.5%;
    /*  background: url("http://24ways.org/examples/compose-to-a-vertical-rhythm/underline.gif");*/
    }
    html>body { font-size: 12px;}
    p, ol,ul,  pre { font-size: 1em; margin-bottom: 1.5em; line-height: 1.5em;}
    sup { vertical-align: super; line-height: .1em}
    pre { padding-left: 1em; }
    
    h1.fronttitle {
            font-size:3em;
            line-height: 2em;
            margin-bottom: 0em;
            text-align: left;
    }
    
    h1.title {
            font-size:1.5em;
            line-height: 1em;
            margin-top: .5em;
            margin-bottom: .5em;
    }
    
    h1 {
            line-height:1em;
            font-size:1.5em;
            font-weight:normal;
            margin:0 0 1em 0;
    }
    h2 {
            font-size:1.1667em;
            line-height: 1.286em;
            margin:1.929em 0 0.643em 0;
            font-weight:normal;
    }
    
    body { font-family: "Georgia"; background-color: #f0f2d0;}
    
    :link { color: #68693F; text-decoration: none; border-bottom: 1px dotted #ccc;}
    :visited { color: #68693F; text-decoration: none; }
    
    h1.title { text-align: right; }
    h1.title a:link, h1.title a:visited, h1.fronttitle a:link, h1.fronttitle a:visited { padding: .3em; padding-top: 3em; text-decoration: none; color: #C3C36E; font-weight: bold; text-transform: uppercase; letter-spacing: .1em; font-family: "Thomas Paine", Georgia; border-bottom: none;}
    #banner { margin-left: 8em; }
    .content { max-width: 30%; margin-left: 3em;}
    hr { border: 0px;}
    hr:after { content: ""; }
    hr + p:first-letter { font-size: 3em; line-height: 1em; margin-right: 2px; display: block; float: left}
    
    .comment { color: #666;}
    .posted { text-align: right; color: #666; font-style: italic; }
    .posted :link, .posted :visited { text-decoration: none; color: #666; border-bottom: 1px dotted;}
    td { vertical-align: top;}
    h2.posttitle :link, h2.posttitle :visited { text-decoration: none; color: black;}
    
    .byline { text-align: right; color: #888; margin-right: 1em;}
    .byline :link, .byline :visited { color: #666; text-decoration: none; background: #ffc;}
    table.main { width: 100%;}
    td.content { padding-left: 4em; width: 30em}
    .sidebar { padding-left: 4em; text-align: right; color: #777; padding-right: .5em; max-width: 20em; float: right;}
    .sidebar :link, .sidebar :visited { color: #8B8A64; text-decoration: none; border-bottom: 1px dotted;}
    
    #comments_show :link, #comments_show :visited, .box :link, .box :visited { color: #555; text-decoration: none; background-color: #D2D6BC; padding: .5em; margin: -.5em; border-bottom: none;}
    blockquote { margin-left: 2em; }
    
    ul, ol { margin-left: 3em;}
    .footnotes ol { margin-left: 1.5em; }
    .footnotes hr { border-top: 1px solid #D2D6BC;  width: 8em; height: 0px; margin-left: 0; margin-top: 0; margin-bottom: 1.5em; padding-top: -1px; padding-bottom: 0px; }
    div.footnotes { color: #666; padding-top: 0;}
    
    .epigraph { padding-left: 10%; color: #666;  }
    .attribution { text-align: right; font-style: italic;}
    
    .footertag { float: right; padding-right: 2em; }
    
    iframe {
            position: fixed;
            bottom: 20px;
            right:20px;
            width: 360px;
    }
    
    @media screen and (max-width: 750px) {
      .content {
        max-width: 70%;
      }
    }
    
    @media screen and (max-width: 390px) {
      .content {
        max-width: 60%;
      }
    }
    
      </style>
    </head>
    <body>
    <h1 class="title"><a href="https://lemmy.world/c/Loom" class="hilite" title="posted from Loom"></a></h1>
    <p class="byline" style="float: right"></a></p>
    
    <div class="content">
    <h1>\(title)</h1>
    \(createQuote(quoteValue))
    \(htmlHR)\(content.map { "<p>\($0)</p>" }.joined())
    """
    }
    
    static var htmlHR: String { "<hr>" }
    
    static func htmlText2(_ trackId: String? = nil) -> String {
        var widget: String = ""
        if let trackId {
            widget = """
                    <iframe width="100%" height="120" scrolling="no" frameborder="no" allow="autoplay" src="https://w.soundcloud.com/player/?url=https%3A//api.soundcloud.com/tracks/\(trackId)&color=%23ff5500&auto_play=true&hide_related=true&show_comments=false&show_user=true&show_reposts=false&show_teaser=false&visual=true"></iframe>
            """
            
        }
        return """
        </div>
        \(widget)
        </body>
        </html>
        """
    }
}
