package cpp.asys;

import asys.native.system.AsysError;

@:native('::hx::asys::net::Server')
extern class Server {
    @:native('::hx::asys::net::Server_obj::open_ipv4')
    static function open_ipv4(ctx : Context, host : String, port : Int, onSuccess : Server->Void, onFailure : AsysError->Void) : Void;

    @:native('::hx::asys::net::Server_obj::open_ipv6')
    static function open_ipv6(ctx : Context, host : String, port : Int, onSuccess : Server->Void, onFailure : AsysError->Void) : Void;

    @:native('::hx::asys::net::Server_obj::open_ipc')
    static function open_ipc(ctx : Context, path : String, onSuccess : Server->Void, onFailure : AsysError->Void) : Void;

    final name : cpp.EnumBase;

    function accept(onSuccess : Socket->Void, onFailure : AsysError->Void) : Void;

    function close(onSuccess : Void->Void, onFailure : AsysError->Void) : Void;
}