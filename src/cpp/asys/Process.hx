package cpp.asys;

import asys.native.system.AsysError;

@:native('::hx::asys::system::Process')
extern class Process {
    @:native('::hx::asys::system::Process::open')
    static function open(ctx : Context, command : String, options : Any, onSuccess : cpp.Pointer<ChildProcess>->Void, onFailure : AsysError->Void) : Void;

    function pid() : Int;
}