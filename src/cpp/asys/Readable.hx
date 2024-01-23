package cpp.asys;

import cpp.asys.AsysError;
import haxe.NoData;
import haxe.Callback;
import haxe.io.Bytes;
import haxe.io.BytesData;
import asys.native.IReadable;
import asys.native.IoException;

@:native('::hx::asys::Readable')
extern class Readable {
    function read(output:BytesData, offset:Int, length:Int, cbSuccess:Int->Void, cbFailure:AsysError->Void):Void;
    function close(cbSuccess:Void->Void, cbFailure:AsysError->Void):Void;
}

class ReadableWrapper implements IReadable {
    final readable : Readable;

    public function new(_readable) {
        readable = _readable;
    }

    public function read(buffer:Bytes, offset:Int, length:Int, callback:Callback<Int>)
    {
        readable.read(
            buffer.getData(),
            offset,
            length,
            callback.success,
            err -> callback.fail(new IoException(err.toIoErrorType())));
    }

    public function close(callback:Callback<NoData>)
    {
        readable.close(
            () -> callback.success(null),
            err -> callback.fail(new IoException(err.toIoErrorType())));
    }
}