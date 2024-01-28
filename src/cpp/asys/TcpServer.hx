package cpp.asys;

@:native('::hx::asys::net::TcpServer')
extern class TcpServer {
    @:native('::hx::asys::net::TcpServer_obj::open_ipv4')
    static function open_ipv4(ctx : Context, host : String, port : Int, options : Dynamic, onSuccess : TcpServer->Void, onFailure : AsysError->Void) : Void;

    @:native('::hx::asys::net::TcpServer_obj::open_ipv6')
    static function open_ipv6(ctx : Context, host : String, port : Int, options : Dynamic, onSuccess : TcpServer->Void, onFailure : AsysError->Void) : Void;

    // @:native('::hx::asys::net::TcpServer_obj::open_ipc')
    // static function open_ipc(ctx : Context, path : String, options : Dynamic, onSuccess : Server->Void, onFailure : AsysError->Void) : Void;

    final localAddress : { host : String, port : Int };

    function accept(onSuccess : TcpSocket->Void, onFailure : AsysError->Void) : Void;

    function close(onSuccess : Void->Void, onFailure : AsysError->Void) : Void;

    function getKeepAlive(cbSuccess : Bool->Void, cbFailure : AsysError->Void) : Void;

    function getSendBufferSize(cbSuccess : Int->Void, cbFailure : AsysError->Void) : Void;

    function getRecvBufferSize(cbSuccess : Int->Void, cbFailure : AsysError->Void) : Void;

    function setKeepAlive(keepAlive : Bool, cbSuccess : Void->Void, cbFailure : AsysError->Void) : Void;

    function setSendBufferSize(size : Int, cbSuccess : Void->Void, cbFailure : AsysError->Void) : Void;

    function setRecvBufferSize(size : Int, cbSuccess : Void->Void, cbFailure : AsysError->Void) : Void;
}