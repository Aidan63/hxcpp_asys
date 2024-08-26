package cpp.asys;

import haxe.NoData;
import haxe.Callback;
import haxe.io.Bytes;
import haxe.io.BytesData;
import asys.native.IWritable;
import asys.native.IoException;
import cpp.asys.AsysError;

@:native('::hx::asys::Writable')
extern class Writable {
    function write(output:BytesData, offset:Int, length:Int, cbSuccess:Int->Void, cbFailure:AsysError->Void):Void;
    function flush(cbSuccess:Void->Void, cbFailure:AsysError->Void):Void;
}