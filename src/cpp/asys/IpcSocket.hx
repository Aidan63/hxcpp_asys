package cpp.asys;

@:native('::hx::asys::net::IpcSocket')
extern class IpcSocket extends Duplex {
    final socketName : String;
    final peerName : String;

    @:native('::hx::asys::net::IpcSocket_obj::bind')
    static function bind(ctx : Context, name : String, onSuccess : IpcSocket->Void, onFailure : AsysError->Void) : Void;
    
    @:native('::hx::asys::net::IpcSocket_obj::connect')
    static function connect(ctx : Context, name : String, onSuccess : IpcSocket->Void, onFailure : AsysError->Void) : Void;
}