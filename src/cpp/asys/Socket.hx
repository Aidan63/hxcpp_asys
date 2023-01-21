package cpp.asys;

import haxe.io.BytesData;
import asys.native.system.AsysError;

@:native('::hx::asys::net::tcp::Socket')
extern class Socket {
    @:native('::hx::asys::net::tcp::Socket_obj::connect_ipv4')
    overload static function connect_ipv4(ctx : Context, host : String, port : Int, onSuccess : Socket->Void, onFailure : AsysError->Void) : Void;

    @:native('::hx::asys::net::tcp::Socket_obj::connect_ipv6')
    overload static function connect_ipv6(ctx : Context, host : String, port : Int, onSuccess : Socket->Void, onFailure : AsysError->Void) : Void;

    function write(input : BytesData, offset : Int, length : Int, cbSuccess : Void->Void, cbFailure : AsysError->Void) : Void;

    function read(output : BytesData, offset : Int, length : Int, cbSuccess : Void->Void, cbFailure : AsysError->Void) : Void;

    function close(cbSuccess : Void->Void, cbFailure : AsysError->Void) : Void;
}