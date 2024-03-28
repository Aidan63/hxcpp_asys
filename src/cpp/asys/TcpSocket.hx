package cpp.asys;

@:native('::hx::asys::net::TcpSocket')
extern class TcpSocket extends Duplex {
    final localAddress : { host : String, port : Int };

    final remoteAddress : { host : String, port : Int };

    @:native('::hx::asys::net::TcpSocket_obj::connect_ipv4')
    static function connect_ipv4(ctx : Context, host : String, port : Int, options : Dynamic, onSuccess : TcpSocket->Void, onFailure : AsysError->Void) : Void;

    @:native('::hx::asys::net::TcpSocket_obj::connect_ipv6')
    static function connect_ipv6(ctx : Context, host : String, port : Int, options : Dynamic, onSuccess : TcpSocket->Void, onFailure : AsysError->Void) : Void;

    function getKeepAlive(cbSuccess : Bool->Void, cbFailure : AsysError->Void) : Void;

    function getSendBufferSize(cbSuccess : Int->Void, cbFailure : AsysError->Void) : Void;

    function getRecvBufferSize(cbSuccess : Int->Void, cbFailure : AsysError->Void) : Void;

    function setKeepAlive(keepAlive : Bool, cbSuccess : Void->Void, cbFailure : AsysError->Void) : Void;

    function setSendBufferSize(size : Int, cbSuccess : Void->Void, cbFailure : AsysError->Void) : Void;

    function setRecvBufferSize(size : Int, cbSuccess : Void->Void, cbFailure : AsysError->Void) : Void;
}