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
    function close(cbSuccess:Void->Void, cbFailure:AsysError->Void):Void;
}

class WritableWrapper implements IWritable {
    final writable : Writable;

    public function new(_writable) {
        writable = _writable;
    }

    public function write(buffer:Bytes, offset:Int, length:Int, callback:Callback<Int>)
    {
        writable.write(
            buffer.getData(),
            offset,
            length,
            callback.success,
            err -> callback.fail(new IoException(err.toIoErrorType())));
    }

    public function flush(callback:Callback<NoData>)
    {
        writable.flush(
            () -> callback.success(null),
            err -> callback.fail(new IoException(err.toIoErrorType())));
    }

    public function close(callback:Callback<NoData>)
    {
        writable.close(
            () -> callback.success(null),
            err -> callback.fail(new IoException(err.toIoErrorType())));
    }
}