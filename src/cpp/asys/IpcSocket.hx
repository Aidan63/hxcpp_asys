package cpp.asys;

@:cpp.ManagedType({ namespace : [ "hx", "asys" ], flags : [ StandardNaming ] })
extern class IpcSocket {
    final socketName : String;
    
    final peerName : String;

    final reader : Readable;

    final writer : Writable;

    static function bind(ctx : Context, name : String, onSuccess : IpcSocket->Void, onFailure : AsysError->Void) : Void;
    static function connect(ctx : Context, name : String, onSuccess : IpcSocket->Void, onFailure : AsysError->Void) : Void;

    function close(cbSuccess : Void->Void, cbFailure : AsysError->Void) : Void;
}