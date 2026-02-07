package cpp.asys;

@:cpp.ManagedType({ namespace : [ "hx", "asys", "system" ], flags : [ StandardNaming ] })
extern class ChildProcess extends Process {
    final stdio_in : Writable;
    final stdio_out : Readable;
    final stdio_err : Readable;

    function exitCode(onSuccess : Int->Void, onFailure : AsysError->Void) : Void;

    function close(onSuccess : Void->Void, onFailure : AsysError->Void) : Void;
}