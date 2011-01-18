# FBJSBridge.as

## What it is

FBJSBridge provides a proxy for old (and difficult to maintain) swfs that routed ExternalInterface calls through facebook's, now deprecated, fbjs-bridge. This allows you to migrate your fbml flash-enabled app to iframes while only making one small change to your javascript functions.

# What's changed

Your javascript will have to be amended slightly because there is no need for js proxy functions (see history below). Because there is no proxy, you need to unpack your own arguments (assuming your swf passes an array), thankfully, this is *very easy.* Suppose you have a function:

    var foo = function( arg1, arg2, arg3, arg4 ) {
      if(arg1 instanceof Array && arg1.length == 4){
        return foo.apply(this,arg1);
      };
      
      /* the rest of your function here */
    }
    
What the three lines do is check to see if the first argument is both an array and has the same length as the number of args you'd like* and then proceeds to return itself `apply`ed using arg1 (which is unpacked by Function.apply)

\* this could be messy if your function expects an array as arg1, you can do your error checking / conditional handling in each function

## Including on your page

When you include your swf and FBJSBridge.swf on the page, you must pass both the same `fb_local_connection` flashvar.

Additionally, you may pass the FBJSBridge the flashvar `debug` which will provide handy error traces in your flashlog.txt file. Here is how i include FBJSBridge.swf using swfobject:

    var fp = {salign:"br", allowscriptaccess:"always"};
    var fv = {
      "fb_local_connection" : "blerg",
      "debug" : "true"
      }; 
    var fa = {};
    swfobject.embedSWF("FBJSBridge.swf", "fbjsbridgeholder", "1","1", "9.0.0", "", fv, fp, fa);

and my own swf i includ like so:

    var flashparams = {salign:"br", allowscriptaccess:"always"};
    var flashvars = {
      "fb_local_connection" : "blerg",
      /*other flashvars here*/
      }; 
    flashattrs = {};
    swfobject.embedSWF("important.swf", "swfholder", "362","412", "9.0.0", "", flashvars, flashparams, flashattrs);

## Some History

Older facebook applications that use FBML and embed flash using a bit of code like this:

    <fb:fbjs-bridge/><fb:swf swfsrc="someswf.swf" width="100" height="100" flashvars="foo=bar" salign="br"/>

The first tag, the `fb:fbjs-bridge` tag embeds a miniature swf which communicates with your own swf using a LocalConnection object. This is because in fbml, you can't reliably perform ExternalInterface calls because all your js is rewritten and sandboxed. Enter the fbjs-bridge!

By including `fb:fbjs-bridge`, a flashvar called fb_local_connection was passed to both the bridge and your swf, in your swf somewhere, you would call javascript by doing this:

    connection.send(fb_local_connection:String, func_name:String, args:Array);

The bridge would do *something like*

    externalinterface.call(jsproxy:String,func_name:String, args:Array);
    
And in turn, on the actual webpage, the jsproxy function would do *something like*

    jsproxy = function(func_name /*string*/, args /*array*/){
      sandbox[func_name].apply(sandbox, args);
    }
    
where

    sandbox[func_name] = function(arg [, arg2[,.. argn]])

This way, your javascript was still sandboxed, but it was being called not by your swf, but by the bridge (and the proxy js function, which both may have been doing some sanitizing or what have you). The proxy works because `Function.apply(context, args)` unpacks an args array into the constituent arguments.

Talk about circuitous!

## Building

You can build this swf by running the following, provided you have installed `mxmlc`
    mxmlc -o=FBJSBridge.swf -file-specs=FBJSBridge.as

However, the swf committed in this repo should work 'out of the box.'