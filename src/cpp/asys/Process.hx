package cpp.asys;

import asys.native.system.AsysError;

@:native('::hx::asys::system::Process')
extern class Process {
    @:native('::hx::asys::system::Process_obj::open')
    static function open(ctx : Context, command : String, options : Any, onSuccess : ChildProcess->Void, onFailure : AsysError->Void) : Void;

    @:native('::hx::asys::system::Process_obj::current')
    static function current(ctx : Context) : CurrentProcess;

    function pid() : Int;

    function sendSignal(signal:cpp.EnumBase, onSuccess:Void->Void, onFailure:AsysError->Void) : Void;
}