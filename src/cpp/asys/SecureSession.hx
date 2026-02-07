package cpp.asys;

import haxe.io.BytesData;

@:cpp.ManagedType({ namespace : [ "hx", "asys" ], flags : [ StandardNaming ] })
extern class SecureSession {
    static function authenticateAsClient(socket:TcpSocket, host:String, options:Any, cbSuccess:SecureSession->Void, cbFailure:String->Void):Void;

    function encode(input:BytesData, offset:Int, length:Int, cbSuccess:BytesData->Void, cbFailure:String->Void):Void;
    function decode(input:BytesData, offset:Int, length:Int, cbSuccess:BytesData->Void, cbFailure:String->Void):Void;
    function close(cbSuccess:BytesData->Void, cbFailure:String->Void):Void;
}