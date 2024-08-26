package cpp.asys;

@:native('::hx::asys::net::IpcSocket')
extern class IpcSocket {
    final socketName : String;
    
    final peerName : String;

    final reader : Readable;

    final writer : Writable;

    @:native('::hx::asys::net::IpcSocket_obj::bind')
    static function bind(ctx : Context, name : String, onSuccess : IpcSocket->Void, onFailure : AsysError->Void) : Void;
    
    @:native('::hx::asys::net::IpcSocket_obj::connect')
    static function connect(ctx : Context, name : String, onSuccess : IpcSocket->Void, onFailure : AsysError->Void) : Void;

    function close(cbSuccess : Void->Void, cbFailure : AsysError->Void) : Void;
}