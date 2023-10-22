package cpp.asys;

import haxe.NoData;
import asys.native.IoException;
import haxe.Exception;
import haxe.Callback;
import asys.native.system.AsysError;
import haxe.io.Bytes;
import asys.native.IReadable;
import haxe.io.BytesData;

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

    public function read(buffer:Bytes, offset:Int, length:Int, callback:Callback<Exception, Int>)
    {
        readable.read(
            buffer.getData(),
            offset,
            length,
            callback.success,
            err -> callback.fail(new IoException(err.toIoErrorType())));
    }

    public function close(callback:Callback<Exception, NoData>)
    {
        readable.close(
            () -> callback.success(null),
            err -> callback.fail(new IoException(err.toIoErrorType())));
    }
}