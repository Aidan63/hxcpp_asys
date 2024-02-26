package cpp.asys;

import haxe.io.BytesData;

@:native('::hx::asys::net::SecureSession')
extern class SecureSession {
    @:native('::hx::asys::net::SecureSession_obj::authenticateAsClient')
    static function authenticateAsClient(socket:TcpSocket, host:String, cbSuccess:SecureSession->Void, cbFailure:String->Void):Void;

    function encode(input:BytesData, offset:Int, length:Int, cbSuccess:BytesData->Void, cbFailure:String->Void):Void;
    function decode(input:BytesData, offset:Int, length:Int, cbSuccess:BytesData->Void, cbFailure:String->Void):Void;
    function close(cbSuccess:BytesData->Void, cbFailure:String->Void):Void;
}