package cpp.asys;

import haxe.io.BytesData;
import asys.native.system.AsysError;

@:native('::hx::asys::net::tcp::Socket')
extern class Socket {
    @:native('::hx::asys::net::tcp::Socket_obj::connect')
    static function connect(ctx : Context, host : String, port : Int, options : Dynamic, onSuccess : Socket->Void, onFailure : AsysError->Void) : Void;

    function write(data : BytesData, offset : Int, length : Int, cbSuccess : Void->Void, cbFailure : AsysError->Void) : Void;
}