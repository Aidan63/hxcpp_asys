package cpp.asys;

import haxe.io.BytesData;
import asys.native.system.AsysError;

@:native('::hx::asys::net::Socket')
extern class Socket {
    final name : Null<cpp.EnumBase>;

    final peer : Null<cpp.EnumBase>;

    @:native('::hx::asys::net::Socket_obj::connect_ipv4')
    static function connect_ipv4(ctx : Context, host : String, port : Int, onSuccess : (Socket, cpp.EnumBase, cpp.EnumBase)->Void, onFailure : AsysError->Void) : Void;

    @:native('::hx::asys::net::Socket_obj::connect_ipv6')
    static function connect_ipv6(ctx : Context, host : String, port : Int, onSuccess : (Socket, cpp.EnumBase, cpp.EnumBase)->Void, onFailure : AsysError->Void) : Void;

    @:native('::hx::asys::net::Socket_obj::connect_ipc')
    static function connect_ipc(ctx : Context, host : String, onSuccess : Socket->Void, onFailure : AsysError->Void) : Void;

    function write(input : BytesData, offset : Int, length : Int, cbSuccess : Void->Void, cbFailure : AsysError->Void) : Void;

    function read(output : BytesData, offset : Int, length : Int, cbSuccess : Void->Void, cbFailure : AsysError->Void) : Void;

    function close(cbSuccess : Void->Void, cbFailure : AsysError->Void) : Void;
}