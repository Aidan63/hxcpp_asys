package cpp.asys;

import haxe.io.BytesData;

@:native('::hx::asys::Duplex')
extern class Duplex {
    function write(input : BytesData, offset : Int, length : Int, cbSuccess : Void->Void, cbFailure : AsysError->Void) : Void;

    function read(output : BytesData, offset : Int, length : Int, cbSuccess : Int->Void, cbFailure : AsysError->Void) : Void;

    function flush(cbSuccess : Void->Void, cbFailure : AsysError->Void) : Void;

    function close(cbSuccess : Void->Void, cbFailure : AsysError->Void) : Void;
}