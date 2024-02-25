package cpp.schannel;

import haxe.io.BytesData;

enum abstract HandshakeResult(Int) {
    final Success = 0;
    final NeedMoreData = 1;
    final TokenGenerated = 2;
}

@:unreflective
@:structAccess
@:native('::hx::schannel::SChannelContext')
@:include('hx/schannel/SChannelSession.h')
@:buildXml("<include name='${HXCPP}/src/hx/libs/schannel/Build.xml'/>")
extern class SChannelContext {
    @:native('::hx::schannel::SChannelContext::create')
    static function create(host:String):cpp.Pointer<SChannelContext>;

    function startHandshake(cbSuccess:BytesData->Void, cbFailure:String->Void):Void;
    function handshake(input:BytesData, cbSuccess:(result:HandshakeResult, data:Null<BytesData>)->Void, cbFailure:String->Void):Void;
    function encode(input:BytesData, offset:Int, length:Int, cbSuccess:BytesData->Void, cbFailure:String->Void):Void;
    function decode(input:BytesData, offset:Int, length:Int, cbSuccess:BytesData->Void, cbFailure:String->Void):Void;
}