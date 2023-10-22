package cpp.asys;

import asys.native.system.AsysError;

@:native('::hx::asys::system::ChildProcess')
extern class ChildProcess extends Process {
    final stdio_in : Writable;
    final stdio_out : Readable;
    final stdio_err : Readable;

    function exitCode(onSuccess : Int->Void, onFailure : AsysError->Void) : Void;

    function close(onSuccess : Void->Void, onFailure : AsysError->Void) : Void;
}