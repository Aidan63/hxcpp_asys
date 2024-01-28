package cpp.asys;

import haxe.io.BytesData;

@:native('::hx::asys::net::TcpSocket')
extern class TcpSocket {
    final localAddress : { host : String, port : Int };

    final remoteAddress : { host : String, port : Int };

    @:native('::hx::asys::net::TcpSocket_obj::connect_ipv4')
    static function connect_ipv4(ctx : Context, host : String, port : Int, options : Dynamic, onSuccess : TcpSocket->Void, onFailure : AsysError->Void) : Void;

    @:native('::hx::asys::net::TcpSocket_obj::connect_ipv6')
    static function connect_ipv6(ctx : Context, host : String, port : Int, options : Dynamic, onSuccess : TcpSocket->Void, onFailure : AsysError->Void) : Void;

    // @:native('::hx::asys::net::TcpSocket_obj::connect_ipc')
    // static function connect_ipc(ctx : Context, host : String, options : Dynamic, onSuccess : Socket->Void, onFailure : AsysError->Void) : Void;

    function write(input : BytesData, offset : Int, length : Int, cbSuccess : Void->Void, cbFailure : AsysError->Void) : Void;

    function read(output : BytesData, offset : Int, length : Int, cbSuccess : Int->Void, cbFailure : AsysError->Void) : Void;

    function flush(cbSuccess : Void->Void, cbFailure : AsysError->Void) : Void;

    function close(cbSuccess : Void->Void, cbFailure : AsysError->Void) : Void;

    function getKeepAlive(cbSuccess : Bool->Void, cbFailure : AsysError->Void) : Void;

    function getSendBufferSize(cbSuccess : Int->Void, cbFailure : AsysError->Void) : Void;

    function getRecvBufferSize(cbSuccess : Int->Void, cbFailure : AsysError->Void) : Void;

    function setKeepAlive(keepAlive : Bool, cbSuccess : Void->Void, cbFailure : AsysError->Void) : Void;

    function setSendBufferSize(size : Int, cbSuccess : Void->Void, cbFailure : AsysError->Void) : Void;

    function setRecvBufferSize(size : Int, cbSuccess : Void->Void, cbFailure : AsysError->Void) : Void;
}