package cpp.asys;

import cpp.asys.AsysError;
import haxe.NoData;
import haxe.Callback;
import haxe.io.Bytes;
import haxe.io.BytesData;
import asys.native.IReadable;
import asys.native.IoException;

@:cpp.ManagedType({ namespace : [ "hx", "asys" ], flags : [ StandardNaming ] })
extern class Readable {
    function read(output:BytesData, offset:Int, length:Int, cbSuccess:Int->Void, cbFailure:AsysError->Void):Void;
}