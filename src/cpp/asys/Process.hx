package cpp.asys;

@:cpp.ManagedType({ namespace : [ "hx", "asys" ], flags : [ StandardNaming ] })
extern class Process {
    static function open(ctx : Context, command : String, options : Any, onSuccess : ChildProcess->Void, onFailure : AsysError->Void) : Void;
    static function current(ctx : Context) : CurrentProcess;

    function pid() : Int;

    function sendSignal(signal:cpp.EnumBase, onSuccess:Void->Void, onFailure:AsysError->Void) : Void;
}