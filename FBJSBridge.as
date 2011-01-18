/*
 FBJSBridge.as
 (C) Jan 2010, Marcos Ojeda, http://generic.cx
 
 ptrace/pformat (c) samizdat drafting co, http://samizdat.cc
 
 released under an MIT License. 
 http://en.wikipedia.org/wiki/MIT_License
*/

package {
import flash.display.*;
import flash.events.*;
import flash.utils.*;
import flash.net.LocalConnection;
import flash.external.ExternalInterface;

[SWF(width='1', height='1', backgroundColor='#ffffff')]
public class FBJSBridge extends Sprite {
  
  private var DEBUG = false;
  private var conn:LocalConnection;
  
  public function FBJSBridge(){
    var args = LoaderInfo(this.root.loaderInfo).parameters;
    // check if debug mode is active
    if(args.hasOwnProperty("debug")){
      this.DEBUG = true;
    }
    
    ptrace( "FBJSBridge:: loaded" );
    
    if(args.hasOwnProperty("fb_local_connection")){
      var fb_lc_id = args.fb_local_connection;
      ptrace("FBJSBridge:: got localconnection: "+fb_lc_id);
      
      conn = new LocalConnection();
      conn.client = this;
      try{
        ptrace("FBJSBridge:: Attempting to connect with '"+fb_lc_id+"'");
        conn.connect(fb_lc_id);
        ptrace("          :: Success!");
        
      }catch (e:Error){
        ptrace("FBJSBridge!> Can't connect!");
        ptrace("          !>'"+fb_lc_id+"' is being used elsewhere!");
      }
      
    }else{
      ptrace("FBJSBridge!> flashvar fb_local_connection not found!")
    }
  }
  
  
  /*callFBJS is called by via the localconnection*/
  public function callFBJS(extfunc,args){
    var eiIsAvailable:Boolean = ExternalInterface.available;
    if(eiIsAvailable){
      ptrace("FBJSBridge:: ExternalInterface available");
      ptrace("FBJSBridge:: Calling js function "+extfunc);
      ptrace("  with arguments:"+pformat(args))
      ExternalInterface.call(extfunc,args);
    }else{
      ptrace("FBJSBridge!> ExternalInterface not available");
    }
  }
  
  /* pformat returns a console.log-like string for use with flashlog.txt */
  public function ptrace(str){
    if (!this.DEBUG){return;}
    trace(str)
  }    
  
  private static function pformat(obj, padding=''){
    var _hasAttr = function(objInQuestion){
      for (var k in objInQuestion){
        return true
      }
      return false
    }

    if (_hasAttr(obj)){
      if (obj is Array){
        var elements = ["[ "]
        for each (var elt in obj){
            elements.push(padding+pformat(elt,padding+'  ')+",")
        }
        var depad = padding.substr(0,Math.max(padding.length-2, 0))
        elements.push(depad+"]")
        return elements.join("\n")
          
      }else{
        var output = ["{"]
        for (var k in obj){
            output.push(padding+k+": "+pformat(obj[k],padding+'  '))
        }
        output.push([padding.substr(2)+"}"])
        return output.join("\n")
      }
    }else{
      if (obj is String) return '"'+String(obj)+'"'
      else if (obj is Number) return String(obj)
      //else return ("<"+getQualifiedClassName(obj).match(/::(.*)/)[1] + ">")
      else return ("<"+getQualifiedClassName(obj) + ">")
    }
  }
  
}

}
